<?php

namespace App\Http\Controllers;

use App\Models\Menu;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class MenuController extends Controller
{
    // Publik: hanya menu aktif (untuk pelanggan)
    public function index()
    {
        $menu = Menu::with('kategori')
            ->where('aktif', true)
            ->orderBy('kategori_id')
            ->orderBy('nama_menu')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data menu berhasil diambil',
            'data' => $menu,
        ]);
    }

    // Admin: semua menu, termasuk yang nonaktif
    public function semua()
    {
        $menu = Menu::with('kategori')
            ->orderBy('kategori_id')
            ->orderBy('nama_menu')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Semua menu berhasil diambil',
            'data' => $menu,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'kategori_id' => 'required|exists:kategori,id',
            'nama_menu' => 'required|string|max:255',
            'harga' => 'required|numeric|min:0',
            'deskripsi' => 'nullable|string',
            'gambar' => 'nullable|string',
            'aktif' => 'nullable|boolean',
        ]);

        $data['aktif'] = $data['aktif'] ?? true;

        $menu = Menu::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Menu berhasil ditambahkan',
            'data' => $menu->load('kategori'),
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $menu = Menu::findOrFail($id);

        $data = $request->validate([
            'kategori_id' => 'sometimes|exists:kategori,id',
            'nama_menu' => 'sometimes|string|max:255',
            'harga' => 'sometimes|numeric|min:0',
            'deskripsi' => 'nullable|string',
            'gambar' => 'nullable|string',
            'aktif' => 'sometimes|boolean',
        ]);

        $menu->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Menu berhasil diperbarui',
            'data' => $menu->load('kategori'),
        ]);
    }

    // Admin: unggah / ganti foto menu (multipart, field "gambar")
    public function uploadGambar(Request $request, $id)
    {
        $request->validate([
            'gambar' => 'required|image|mimes:jpg,jpeg,png,webp|max:3072',
        ]);

        $menu = Menu::findOrFail($id);

        // Hapus foto lama (kalau berupa file di storage, bukan link luar)
        $lama = $menu->gambar;
        if ($lama && !str_starts_with($lama, 'http')) {
            Storage::disk('public')->delete($lama);
        }

        $menu->gambar = $request->file('gambar')->store('menu', 'public');
        $menu->save();

        return response()->json([
            'success' => true,
            'message' => 'Foto menu berhasil diunggah',
            'data' => $menu->load('kategori'),
        ]);
    }

    public function destroy($id)
    {
        $menu = Menu::findOrFail($id);
        $gambar = $menu->gambar;

        try {
            $menu->delete();
        } catch (QueryException $e) {
            // Menu yang sudah pernah dipesan tidak boleh dihapus (terikat riwayat transaksi)
            return response()->json([
                'success' => false,
                'message' => 'Menu ini sudah pernah dipesan. Nonaktifkan saja, jangan dihapus.',
            ], 409);
        }

        if ($gambar && !str_starts_with($gambar, 'http')) {
            Storage::disk('public')->delete($gambar);
        }

        return response()->json([
            'success' => true,
            'message' => 'Menu berhasil dihapus',
        ]);
    }
}