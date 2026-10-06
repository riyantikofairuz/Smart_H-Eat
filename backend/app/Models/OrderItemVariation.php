<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItemVariation extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_item_id',
        'group_name',
        'option_name',
        'extra_price',
    ];

    protected $casts = [
        'extra_price' => 'integer',
    ];

    public function orderItem()
    {
        return $this->belongsTo(OrderItem::class);
    }
}
