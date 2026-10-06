<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RestockLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'menu_id',
        'operator_id',
        'qty_added',
        'stock_before',
        'stock_after',
        'note',
    ];

    protected $casts = [
        'qty_added' => 'integer',
        'stock_before' => 'integer',
        'stock_after' => 'integer',
    ];

    public function menu()
    {
        return $this->belongsTo(Menu::class);
    }

    public function operator()
    {
        return $this->belongsTo(Operator::class);
    }
}
