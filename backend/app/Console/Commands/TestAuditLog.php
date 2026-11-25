<?php

namespace App\Console\Commands;

use App\Models\AuditLog;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Throwable;

class TestAuditLog extends Command
{
    protected $signature = 'audit:test';

    protected $description = 'Menguji pencatatan audit log Smart H-EAT';

    public function handle(): int
    {
        try {
            DB::transaction(function () {
                AuditLog::create([
                    'actor' => 'TEST_OPERATOR',
                    'action' => 'CREATE',
                    'object_type' => 'TEST_RECORD',
                    'object_id' => 'TEST-' . uniqid(),
                    'result' => 'SUCCESS',
                    'occurred_at' => now(),
                ]);
            });

            $this->info('AUDIT LOG: BERHASIL disimpan.');

            $latest = AuditLog::latest('id')->first();

            $this->table(
                ['Aktor', 'Aksi', 'Objek', 'ID Objek', 'Hasil', 'Waktu'],
                [[
                    $latest->actor,
                    $latest->action,
                    $latest->object_type,
                    $latest->object_id,
                    $latest->result,
                    $latest->occurred_at->toDateTimeString(),
                ]]
            );

            return self::SUCCESS;
        } catch (Throwable $e) {
            $this->error('AUDIT LOG: GAGAL disimpan.');
            $this->error($e->getMessage());

            return self::FAILURE;
        }
    }
}
