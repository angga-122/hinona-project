<?php

namespace App\Http\Controllers;

use App\Models\DetailTransaksi;
use App\Models\Meja;
use App\Models\Menu;
use App\Models\Transaksi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransaksiController extends Controller
{
    // ------------------------------------------------------------
    // Helper: isi ulang item pesanan & hitung total
    // ------------------------------------------------------------
    private function isiItem(Transaksi $transaksi, array $items): void
    {
        $transaksi->detail()->delete();

        $total = 0;

        foreach ($items as $item) {
            $menu = Menu::findOrFail($item['menu_id']);

            $subtotal = $menu->harga * $item['jumlah'];

            DetailTransaksi::create([
                'transaksi_id' => $transaksi->id,
                'menu_id' => $menu->id,
                'jumlah' => $item['jumlah'],
                'harga' => $menu->harga,
                'subtotal' => $subtotal,
            ]);

            $total += $subtotal;
        }

        $transaksi->update(['total' => $total]);
    }

    private function muat(Transaksi $transaksi)
    {
        return $transaksi->fresh(['detail.menu', 'meja', 'user']);
    }

    // ------------------------------------------------------------
    // PUBLIK: pelanggan mengirim pesanan dari meja
    // ------------------------------------------------------------
    public function storePelanggan(Request $request)
    {
        $data = $request->validate([
            'meja_id' => 'required|exists:meja,id',
            'items' => 'required|array|min:1',
            'items.*.menu_id' => 'required|exists:menu,id',
            'items.*.jumlah' => 'required|integer|min:1',
        ]);

        $transaksi = DB::transaction(function () use ($data) {
            $transaksi = Transaksi::create([
                'meja_id' => $data['meja_id'],
                'status' => 'menunggu',
                'total' => 0,
            ]);

            $this->isiItem($transaksi, $data['items']);

            return $transaksi;
        });

        return response()->json([
            'success' => true,
            'message' => 'Pesanan berhasil dikirim',
            'data' => $this->muat($transaksi),
        ], 201);
    }

    // ------------------------------------------------------------
    // PUBLIK: status pesanan (hanya data aman, 24 jam terakhir)
    // ------------------------------------------------------------
    public function pesananPublik()
    {
        $data = Transaksi::with('meja:id,nomor_meja')
            ->where('created_at', '>=', now()->subDay())
            ->latest()
            ->get(['id', 'meja_id', 'total', 'status', 'created_at']);

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    // ------------------------------------------------------------
    // KASIR
    // ------------------------------------------------------------
    public function mejaAktif()
    {
        return response()->json([
            'success' => true,
            'data' => Meja::where('aktif', true)->orderBy('id')->get(),
        ]);
    }

    public function index(Request $request)
    {
        $query = Transaksi::with(['detail.menu', 'meja', 'user'])
            ->latest()
            ->limit(300);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        return response()->json([
            'success' => true,
            'data' => $query->get(),
        ]);
    }

    public function show($id)
    {
        $transaksi = Transaksi::with(['detail.menu', 'meja', 'user'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $transaksi,
        ]);
    }

    // Kasir membuat pesanan langsung (status langsung diproses)
    public function store(Request $request)
    {
        $data = $request->validate([
            'meja_id' => 'nullable|exists:meja,id',
            'items' => 'required|array|min:1',
            'items.*.menu_id' => 'required|exists:menu,id',
            'items.*.jumlah' => 'required|integer|min:1',
        ]);

        $transaksi = DB::transaction(function () use ($data, $request) {
            $transaksi = Transaksi::create([
                'user_id' => $request->user()->id,
                'meja_id' => $data['meja_id'] ?? null,
                'status' => 'diproses',
                'total' => 0,
            ]);

            $this->isiItem($transaksi, $data['items']);

            return $transaksi;
        });

        return response()->json([
            'success' => true,
            'message' => 'Pesanan berhasil dibuat',
            'data' => $this->muat($transaksi),
        ], 201);
    }

    // Kasir mengubah pesanan (selama belum dibayar)
    public function update(Request $request, $id)
    {
        $transaksi = Transaksi::findOrFail($id);

        if (in_array($transaksi->status, ['selesai', 'dibatalkan'], true)) {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan yang sudah selesai tidak bisa diubah',
            ], 422);
        }

        $data = $request->validate([
            'meja_id' => 'nullable|exists:meja,id',
            'items' => 'required|array|min:1',
            'items.*.menu_id' => 'required|exists:menu,id',
            'items.*.jumlah' => 'required|integer|min:1',
        ]);

        DB::transaction(function () use ($transaksi, $data) {
            $transaksi->update(['meja_id' => $data['meja_id'] ?? null]);
            $this->isiItem($transaksi, $data['items']);
        });

        return response()->json([
            'success' => true,
            'message' => 'Pesanan berhasil diperbarui',
            'data' => $this->muat($transaksi),
        ]);
    }

    // Kasir menghapus pesanan (selama belum dibayar)
    public function destroy($id)
    {
        $transaksi = Transaksi::findOrFail($id);

        if ($transaksi->status === 'selesai') {
            return response()->json([
                'success' => false,
                'message' => 'Transaksi yang sudah dibayar tidak bisa dihapus',
            ], 422);
        }

        $transaksi->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pesanan berhasil dihapus',
        ]);
    }

    // Kasir menerima pesanan dari pelanggan: menunggu -> diproses
    public function terima(Request $request, $id)
    {
        $transaksi = Transaksi::findOrFail($id);

        if ($transaksi->status !== 'menunggu') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan ini sudah diterima atau sudah selesai',
            ], 422);
        }

        $transaksi->update([
            'status' => 'diproses',
            'user_id' => $request->user()->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pesanan diterima',
            'data' => $this->muat($transaksi),
        ]);
    }

    // Kasir memproses pembayaran
    public function prosesPembayaran(Request $request, $id)
    {
        $data = $request->validate([
            'metode_pembayaran' => 'required|in:tunai',
            'uang_bayar' => 'nullable|numeric|min:0',
        ]);

        $transaksi = Transaksi::findOrFail($id);

        if ($transaksi->status === 'selesai') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan ini sudah dibayar',
            ], 422);
        }

        if ($transaksi->status === 'dibatalkan') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan ini sudah dibatalkan',
            ], 422);
        }

        $total = (float) $transaksi->total;

        // Non-tunai: nominal otomatis sama dengan total
        $uang = $data['metode_pembayaran'] === 'tunai'
            ? (float) ($data['uang_bayar'] ?? 0)
            : $total;

        if ($uang < $total) {
            return response()->json([
                'success' => false,
                'message' => 'Uang pembayaran kurang',
            ], 422);
        }

        $transaksi->update([
            'user_id' => $request->user()->id,
            'uang_bayar' => $uang,
            'kembalian' => $uang - $total,
            'metode_pembayaran' => $data['metode_pembayaran'],
            'status' => 'selesai',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil',
            'data' => $this->muat($transaksi),
        ]);
    }
}