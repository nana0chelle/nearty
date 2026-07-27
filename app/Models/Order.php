<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'user_id', 'driver_id', 'item_name', 'pickup_location', 
        'destination_location', 'fee', 'status', 'proof_image', 'payment_method',
        'pickup_lat', 'pickup_lng', 'dest_lat', 'dest_lng'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function review()
    {
        return $this->hasOne(Review::class, 'order_id');
    }
}
