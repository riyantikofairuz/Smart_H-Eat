<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeviceCommand extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'command',
        'status',
        'sent_at',
        'execute_at',
    ];

    protected $casts = [
        'sent_at' => 'datetime',
        'execute_at' => 'datetime',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
