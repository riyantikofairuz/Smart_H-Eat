<?php

use Illuminate\Support\Facades\DB;

require __DIR__ . '/../../vendor/autoload.php';

$app = require __DIR__ . '/../../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$testCode = 'TEST-TX-' . strtoupper(bin2hex(random_bytes(4)));
$rollbackCode = $testCode . '-RB';

echo "Database: " . DB::connection()->getDatabaseName() . PHP_EOL;

// Skenario 1: COMMIT
DB::transaction(function () use ($testCode) {
    DB::table('orders')->insert([
        'order_code' => $testCode,
        'queue_number' => null,
        'total_amount' => 10000,
        'status' => 'pending',
        'expired_at' => null,
        'paid_at' => null,
        'created_at' => now(),
        'updated_at' => now(),
    ]);
});

$commitExists = DB::table('orders')
    ->where('order_code', $testCode)
    ->exists();

echo 'COMMIT: ' .
    ($commitExists ? 'BERHASIL' : 'GAGAL') . PHP_EOL;

// Skenario 2: ROLLBACK
try {
    DB::transaction(function () use ($rollbackCode) {
        DB::table('orders')->insert([
            'order_code' => $rollbackCode,
            'queue_number' => null,
            'total_amount' => 20000,
            'status' => 'pending',
            'expired_at' => null,
            'paid_at' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Simulasikan kegagalan setelah insert.
        throw new RuntimeException('Simulasi kegagalan');
    });
} catch (RuntimeException $e) {
    echo 'Simulasi kegagalan: tertangkap' . PHP_EOL;
}

$rollbackExists = DB::table('orders')
    ->where('order_code', $rollbackCode)
    ->exists();

echo 'ROLLBACK: ' .
    (!$rollbackExists ? 'BERHASIL' : 'GAGAL') . PHP_EOL;

echo "Kode COMMIT: {$testCode}" . PHP_EOL;
echo "Kode ROLLBACK: {$rollbackCode}" . PHP_EOL;
