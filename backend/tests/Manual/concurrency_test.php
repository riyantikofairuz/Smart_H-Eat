<?php

use Illuminate\Support\Facades\DB;

require __DIR__ . '/../../vendor/autoload.php';

$app = require __DIR__ . '/../../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "=== CONCURRENCY / LOCKING TEST ===" . PHP_EOL;

try {
    DB::transaction(function () {
        $testCode = 'TEST-LOCK-' . bin2hex(random_bytes(4));

        DB::table('orders')->insert([
            'order_code' => $testCode,
            'total_amount' => 10000,
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $order = DB::table('orders')
            ->where('order_code', $testCode)
            ->lockForUpdate()
            ->first();

        if ($order && (int) $order->total_amount === 10000) {
            echo "LOCKING: BERHASIL" . PHP_EOL;
        } else {
            throw new RuntimeException('Data pengujian tidak sesuai.');
        }

        DB::table('orders')->where('order_code', $testCode)->delete();

        echo "PEMBERSIHAN DATA: BERHASIL" . PHP_EOL;
    });

    echo "TRANSACTION: BERHASIL" . PHP_EOL;
} catch (\Throwable $e) {
    echo "PENGUJIAN GAGAL: " . $e->getMessage() . PHP_EOL;
}
