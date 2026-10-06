<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('menu_variation_options', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained('menu_variation_groups')->cascadeOnDelete();
            $table->string('name');
            $table->integer('extra_price')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('menu_variation_options');
    }
};
