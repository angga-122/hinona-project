<?php

namespace Database\Seeders;

use App\Models\Kategori;
use App\Models\Meja;
use App\Models\Menu;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ===== USER STAFF =====
        // Password otomatis di-hash oleh cast 'hashed' di model User
        $users = [
            ['Admin Hinona',   'admin@hinona.test',   'admin'],
            ['Kasir Hinona',   'kasir@hinona.test',   'kasir'],
            ['Manager Hinona', 'manager@hinona.test', 'manager'],
        ];

        foreach ($users as [$name, $email, $role]) {
            User::updateOrCreate(
                ['email' => $email],
                ['name' => $name, 'password' => 'password', 'role' => $role]
            );
        }

        // ===== KATEGORI =====
        $kategori = [];
        foreach (['Coffee', 'Non Coffee', 'Tea', 'Food', 'Snack'] as $nama) {
            $kategori[$nama] = Kategori::firstOrCreate(['nama_kategori' => $nama]);
        }

        // ===== MENU =====
        $menus = [
            ['Coffee',     'Americano',    18000, 'Espresso dengan air'],
            ['Coffee',     'Coffee Latte', 22000, 'Espresso dengan susu'],
            ['Non Coffee', 'Chocolate',    20000, 'Minuman cokelat'],
            ['Tea',        'Ice Tea',      10000, 'Es teh'],
            ['Food',       'French Fries', 18000, 'Kentang goreng'],
            ['Snack',      'Croissant',    20000, 'Croissant butter'],
        ];

        foreach ($menus as [$kat, $nama, $harga, $deskripsi]) {
            Menu::firstOrCreate(
                ['nama_menu' => $nama],
                [
                    'kategori_id' => $kategori[$kat]->id,
                    'harga'       => $harga,
                    'deskripsi'   => $deskripsi,
                    'aktif'       => true,
                ]
            );
        }

        // ===== MEJA (QR = HINONA-MEJA-1 s/d HINONA-MEJA-10) =====
        for ($i = 1; $i <= 10; $i++) {
            Meja::firstOrCreate(
                ['kode_qr' => 'HINONA-MEJA-' . $i],
                ['nomor_meja' => 'Meja ' . $i, 'aktif' => true]
            );
        }
    }
}