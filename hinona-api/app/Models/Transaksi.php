<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaksi extends Model
{
    protected $table = 'transaksi';

    protected $fillable = [
        'user_id',
        'meja_id',
        'total',
        'uang_bayar',
        'kembalian',
        'metode_pembayaran',
        'status',
    ];

    protected $casts = [
        'total' => 'decimal:2',
        'uang_bayar' => 'decimal:2',
        'kembalian' => 'decimal:2',
    ];

    public function detail()
    {
        return $this->hasMany(DetailTransaksi::class);
    }

    public function meja()
    {
        return $this->belongsTo(Meja::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}