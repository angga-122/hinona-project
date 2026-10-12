<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * Laporan untuk Pemilik / Manager.
 *
 * Semua endpoint menerima filter periode (opsional):
 *   ?tanggal_mulai=YYYY-MM-DD&tanggal_selesai=YYYY-MM-DD
 *
 * Yang dihitung sebagai penjualan hanya transaksi berstatus "selesai" (sudah dibayar).
 */
class LaporanController extends Controller
{
    // ------------------------------------------------------------
    // Helper: terapkan filter periode ke query (Eloquent / Query Builder)
    // ------------------------------------------------------------
    private function periode($query, Request $request, string $kolom = 'transaksi.created_at')
    {
        if ($request->filled('tanggal_mulai')) {
            $query->whereDate($kolom, '>=', $request->tanggal_mulai);
        }

        if ($request->filled('tanggal_selesai')) {
            $query->whereDate($kolom, '<=', $request->tanggal_selesai);
        }

        return $query;
    }

    private function transaksiSelesai(Request $request)
    {
        $query = DB::table('transaksi')->where('transaksi.status', 'selesai');

        return $this->periode($query, $request);
    }

    // ------------------------------------------------------------
    // GET /laporan/pendapatan
    // ------------------------------------------------------------
    public function pendapatan(Request $request)
    {
        $query = $this->transaksiSelesai($request);

        $total = (float) (clone $query)->sum('transaksi.total');
        $jumlah = (clone $query)->count();

        return response()->json([
            'success' => true,
            'message' => 'Laporan pendapatan berhasil diambil',
            'data' => [
                'total_pendapatan' => $total,
                'jumlah_transaksi' => $jumlah,
                'rata_rata_transaksi' => $jumlah > 0 ? round($total / $jumlah, 2) : 0,
            ],
        ]);
    }

    // ------------------------------------------------------------
    // GET /laporan/menu-terlaris   (opsional: ?limit=10)
    // ------------------------------------------------------------
    public function menuTerlaris(Request $request)
    {
        $query = DB::table('detail_transaksi')
            ->join('transaksi', 'detail_transaksi.transaksi_id', '=', 'transaksi.id')
            ->join('menu', 'detail_transaksi.menu_id', '=', 'menu.id')
            ->join('kategori', 'menu.kategori_id', '=', 'kategori.id')
            ->where('transaksi.status', 'selesai');

        $this->periode($query, $request);

        $query->select(
            'menu.id',
            'menu.nama_menu',
            'kategori.nama_kategori',
            DB::raw('SUM(detail_transaksi.jumlah) as total_terjual'),
            DB::raw('SUM(detail_transaksi.subtotal) as total_pendapatan')
        )
            ->groupBy('menu.id', 'menu.nama_menu', 'kategori.nama_kategori')
            ->orderByDesc('total_terjual')
            ->orderBy('menu.nama_menu');

        if ($request->filled('limit')) {
            $query->limit(max(1, min((int) $request->limit, 100)));
        }

        return response()->json([
            'success' => true,
            'message' => 'Laporan menu terlaris berhasil diambil',
            'data' => $query->get(),
        ]);
    }

    // ------------------------------------------------------------
    // GET /laporan/statistik
    // Ringkasan + data grafik untuk dashboard manager
    // ------------------------------------------------------------
    public function statistik(Request $request)
    {
        $selesai = $this->transaksiSelesai($request);

        $total = (float) (clone $selesai)->sum('transaksi.total');
        $jumlah = (clone $selesai)->count();

        // Jumlah item terjual
        $itemTerjual = (int) $this->periode(
            DB::table('detail_transaksi')
                ->join('transaksi', 'detail_transaksi.transaksi_id', '=', 'transaksi.id')
                ->where('transaksi.status', 'selesai'),
            $request
        )->sum('detail_transaksi.jumlah');

        // Jumlah transaksi per status (semua status, pada periode yang sama)
        $perStatus = $this->periode(DB::table('transaksi'), $request)
            ->select('transaksi.status', DB::raw('COUNT(*) as jumlah'))
            ->groupBy('transaksi.status')
            ->pluck('jumlah', 'status');

        // Pendapatan per hari
        $perHari = (clone $selesai)
            ->select(
                DB::raw('DATE(transaksi.created_at) as tanggal'),
                DB::raw('SUM(transaksi.total) as pendapatan'),
                DB::raw('COUNT(*) as jumlah')
            )
            ->groupBy(DB::raw('DATE(transaksi.created_at)'))
            ->orderBy('tanggal')
            ->get();

        // Per metode pembayaran
        $perMetode = (clone $selesai)
            ->select(
                DB::raw("COALESCE(transaksi.metode_pembayaran, 'lainnya') as metode"),
                DB::raw('COUNT(*) as jumlah'),
                DB::raw('SUM(transaksi.total) as total')
            )
            ->groupBy(DB::raw("COALESCE(transaksi.metode_pembayaran, 'lainnya')"))
            ->orderByDesc('total')
            ->get();

        // Per kategori menu
        $perKategori = $this->periode(
            DB::table('detail_transaksi')
                ->join('transaksi', 'detail_transaksi.transaksi_id', '=', 'transaksi.id')
                ->join('menu', 'detail_transaksi.menu_id', '=', 'menu.id')
                ->join('kategori', 'menu.kategori_id', '=', 'kategori.id')
                ->where('transaksi.status', 'selesai'),
            $request
        )
            ->select(
                'kategori.nama_kategori as kategori',
                DB::raw('SUM(detail_transaksi.jumlah) as total_terjual'),
                DB::raw('SUM(detail_transaksi.subtotal) as total_pendapatan')
            )
            ->groupBy('kategori.id', 'kategori.nama_kategori')
            ->orderByDesc('total_pendapatan')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Statistik penjualan berhasil diambil',
            'data' => [
                'total_pendapatan' => $total,
                'jumlah_transaksi' => $jumlah,
                'rata_rata_transaksi' => $jumlah > 0 ? round($total / $jumlah, 2) : 0,
                'item_terjual' => $itemTerjual,
                'transaksi_dibatalkan' => (int) ($perStatus['dibatalkan'] ?? 0),
                'transaksi_berjalan' => (int) ($perStatus['menunggu'] ?? 0) + (int) ($perStatus['diproses'] ?? 0),
                'per_hari' => $perHari,
                'per_metode' => $perMetode,
                'per_kategori' => $perKategori,
            ],
        ]);
    }

    // ------------------------------------------------------------
    // GET /laporan/transaksi
    // Daftar transaksi (selesai) berdasarkan periode
    // ------------------------------------------------------------
    public function transaksi(Request $request)
    {
        $query = Transaksi::with(['detail.menu', 'meja', 'user'])
            ->where('status', 'selesai');

        if ($request->filled('tanggal_mulai')) {
            $query->whereDate('created_at', '>=', $request->tanggal_mulai);
        }

        if ($request->filled('tanggal_selesai')) {
            $query->whereDate('created_at', '<=', $request->tanggal_selesai);
        }

        return response()->json([
            'success' => true,
            'message' => 'Riwayat transaksi berhasil diambil',
            'data' => $query->latest()->limit(500)->get(),
        ]);
    }
}