<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Menu extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'name',
        'description',
        'price',
        'image_url',
        'stock',
        'min_stock_threshold',
        'is_active',
    ];

    protected $casts = [
        'price' => 'integer',
        'stock' => 'integer',
        'min_stock_threshold' => 'integer',
        'is_active' => 'boolean',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function variationGroups()
    {
        return $this->hasMany(MenuVariationGroup::class);
    }

    public function restockLogs()
    {
        return $this->hasMany(RestockLog::class);
    }

    public function salesSummaries()
    {
        return $this->hasMany(SalesSummary::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}
