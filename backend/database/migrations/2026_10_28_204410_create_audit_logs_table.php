
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            $table->string('actor', 100);
            $table->string('action', 100);
            $table->string('object_type', 100);
            $table->string('object_id', 100)->nullable();
            $table->string('result', 30);
            $table->timestamp('occurred_at')->useCurrent();

            $table->timestamps();

            $table->index(['object_type', 'object_id']);
            $table->index('occurred_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
