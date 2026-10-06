<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SalesSummary extends Model
{
    use HasFactory;

    protected $fillable = [
        'menu_id',
        'summary_date',
        'qty_sold',
        'revenue',
        'order_count',
    ];

    protected $casts = [
        'summary_date' => 'date',
        'qty_sold' => 'integer',
        'revenue' => 'integer',
        'order_count' => 'integer',
    ];

    public function menu()
    {
        return $this->belongsTo(Menu::class);
    }
}
