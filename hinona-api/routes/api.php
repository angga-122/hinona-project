<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\AuthController;
use App\Http\Controllers\MenuController;
use App\Http\Controllers\TransaksiController;
use App\Http\Controllers\PelangganController;
use App\Http\Controllers\KategoriController;
use App\Http\Controllers\MejaController;
use App\Http\Controllers\LaporanController;

// ======================================================
// PUBLIK (pelanggan)
// ======================================================

Route::post('/login', [AuthController::class, 'login']);

Route::get('/menu', [MenuController::class, 'index']);

Route::post('/pelanggan', [PelangganController::class, 'store']);
Route::get('/pelanggan/meja/{kodeQr}', [PelangganController::class, 'meja']);

Route::post('/pesanan', [TransaksiController::class, 'storePelanggan']);
Route::get('/pesanan', [TransaksiController::class, 'pesananPublik']);


// ======================================================
// WAJIB LOGIN
// ======================================================

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // ---------------- KASIR (admin juga boleh) ----------------
    Route::middleware('role:kasir,admin')->group(function () {
        Route::get('/kasir/meja', [TransaksiController::class, 'mejaAktif']);

        Route::get('/transaksi', [TransaksiController::class, 'index']);
        Route::post('/transaksi', [TransaksiController::class, 'store']);
        Route::get('/transaksi/{id}', [TransaksiController::class, 'show']);
        Route::put('/transaksi/{id}', [TransaksiController::class, 'update']);
        Route::delete('/transaksi/{id}', [TransaksiController::class, 'destroy']);
        Route::post('/transaksi/{id}/terima', [TransaksiController::class, 'terima']);
        Route::post('/transaksi/{id}/bayar', [TransaksiController::class, 'prosesPembayaran']);
    });

    // ---------------- ADMIN ----------------
    Route::middleware('role:admin')->group(function () {
        Route::apiResource('kategori', KategoriController::class);
        Route::apiResource('meja', MejaController::class);

        Route::get('/admin/menu', [MenuController::class, 'semua']);
        Route::post('/menu', [MenuController::class, 'store']);
        Route::post('/menu/{id}/gambar', [MenuController::class, 'uploadGambar']);
        Route::put('/menu/{id}', [MenuController::class, 'update']);
        Route::delete('/menu/{id}', [MenuController::class, 'destroy']);

        Route::get('/pelanggan', [PelangganController::class, 'index']);
    });

        // ---------------- MANAGER / PEMILIK ----------------
    Route::middleware('role:manager,admin')->group(function () {
        Route::get('/laporan/pendapatan', [LaporanController::class, 'pendapatan']);
        Route::get('/laporan/menu-terlaris', [LaporanController::class, 'menuTerlaris']);
        Route::get('/laporan/statistik', [LaporanController::class, 'statistik']);
        Route::get('/laporan/transaksi', [LaporanController::class, 'transaksi']);
    });
});