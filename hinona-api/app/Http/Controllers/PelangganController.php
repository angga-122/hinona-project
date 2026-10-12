<?php

namespace App\Http\Controllers;

use App\Models\Pelanggan;
use App\Models\Meja;
use Illuminate\Http\Request;

class PelangganController extends Controller
{
    public function index()
    {
        $data = Pelanggan::with('meja')->get();

        return response()->json([
            'success' => true,
            'message' => 'Data pelanggan berhasil diambil',
            'data' => $data,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'nullable|string|max:255',
            'no_hp' => 'nullable|string|max:30',
            'meja_id' => 'nullable|exists:meja,id',
        ]);

        $pelanggan = Pelanggan::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Data pelanggan berhasil disimpan',
            'data' => $pelanggan->load('meja'),
        ], 201);
    }

    public function meja($kodeQr)
    {
        $meja = Meja::where('kode_qr', $kodeQr)
            ->where('aktif', true)
            ->first();

        if (!$meja) {
            return response()->json([
                'success' => false,
                'message' => 'QR Code atau meja tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Meja berhasil dikenali',
            'data' => $meja,
        ]);
    }
}