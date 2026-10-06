<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_code',
        'queue_number',
        'total_amount',
        'status',
        'expired_at',
        'paid_at',
    ];

    protected $casts = [
        'queue_number' => 'integer',
        'total_amount' => 'integer',
        'expired_at' => 'datetime',
        'paid_at' => 'datetime',
    ];

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function payment()
    {
        return $this->hasOne(Payment::class);
    }

    public function deviceCommands()
    {
        return $this->hasMany(DeviceCommand::class);
    }
}
