<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Meja extends Model
{
    protected $table = 'meja';

    protected $fillable = [
        'nomor_meja',
        'kode_qr',
        'aktif',
    ];

    protected $casts = [
        'aktif' => 'boolean',
    ];
}