<?php

namespace App\Http\Controllers;

use App\Models\Meja;
use Illuminate\Http\Request;

class MejaController extends Controller
{
    public function index()
    {
        return response()->json([
            'success' => true,
            'message' => 'Data meja berhasil diambil',
            'data' => Meja::all(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nomor_meja' => 'required|string|max:255|unique:meja,nomor_meja',
            'kode_qr' => 'required|string|max:255|unique:meja,kode_qr',
            'aktif' => 'boolean',
        ]);

        $meja = Meja::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Meja berhasil ditambahkan',
            'data' => $meja,
        ], 201);
    }

    public function show($id)
    {
        $meja = Meja::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $meja,
        ]);
    }

    public function update(Request $request, $id)
    {
        $meja = Meja::findOrFail($id);

        $validated = $request->validate([
            'nomor_meja' => 'required|string|max:255|unique:meja,nomor_meja,' . $id,
            'kode_qr' => 'required|string|max:255|unique:meja,kode_qr,' . $id,
            'aktif' => 'boolean',
        ]);

        $meja->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Meja berhasil diperbarui',
            'data' => $meja,
        ]);
    }

    public function destroy($id)
    {
        $meja = Meja::findOrFail($id);
        $meja->delete();

        return response()->json([
            'success' => true,
            'message' => 'Meja berhasil dihapus',
        ]);
    }
}
