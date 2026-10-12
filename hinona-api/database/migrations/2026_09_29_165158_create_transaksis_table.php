<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transaksi', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            $table->foreignId('meja_id')
                ->nullable()
                ->constrained('meja')
                ->nullOnDelete();

            $table->decimal('total', 12, 2)->default(0);
            $table->decimal('uang_bayar', 12, 2)->default(0);
            $table->decimal('kembalian', 12, 2)->default(0);

            $table->string('metode_pembayaran')->nullable();

            $table->enum('status', [
                'menunggu',
                'diproses',
                'selesai',
                'dibatalkan'
            ])->default('menunggu');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transaksi');
    }
};