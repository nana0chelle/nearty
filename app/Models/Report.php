<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    protected $fillable = ['user_id', 'reported_id', 'order_id', 'reason', 'description', 'status'];
}
