<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'driver_id',
        'item_name',
        'pickup_location',
        'destination_location',
        'pickup_lat',
        'pickup_lng',
        'dest_lat',
        'dest_lng',
        'fee',
        'payment_method',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'pickup_lat' => 'float',
            'pickup_lng' => 'float',
            'dest_lat' => 'float',
            'dest_lng' => 'float',
            'fee' => 'integer',
        ];
    }

    public function user()
    {
        // pembeli / buyer
        return $this->belongsTo(User::class, 'user_id');
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function review()
    {
        return $this->hasOne(Review::class);
    }
}
