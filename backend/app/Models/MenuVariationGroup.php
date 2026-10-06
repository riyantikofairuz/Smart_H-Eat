<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MenuVariationGroup extends Model
{
    use HasFactory;

    protected $fillable = [
        'menu_id',
        'name',
        'is_required',
    ];

    protected $casts = [
        'is_required' => 'boolean',
    ];

    public function menu()
    {
        return $this->belongsTo(Menu::class);
    }

    public function variationOptions()
    {
        return $this->hasMany(MenuVariationOption::class, 'group_id');
    }
}
