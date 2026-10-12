<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('menu', function (Blueprint $table) {
            $table->id();

            $table->foreignId('kategori_id')
                ->constrained('kategori')
                ->cascadeOnDelete();

            $table->string('nama_menu');
            $table->decimal('harga', 12, 2);
            $table->text('deskripsi')->nullable();
            $table->string('gambar')->nullable();
            $table->boolean('aktif')->default(true);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('menu');
    }
};