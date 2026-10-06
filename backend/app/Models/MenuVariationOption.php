<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MenuVariationOption extends Model
{
    use HasFactory;

    protected $fillable = [
        'group_id',
        'name',
        'extra_price',
    ];

    protected $casts = [
        'extra_price' => 'integer',
    ];

    public function variationGroup()
    {
        return $this->belongsTo(MenuVariationGroup::class, 'group_id');
    }
}
