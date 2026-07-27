<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\Review;

class ReviewController extends Controller
{
    public function store(Request $request, $id)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string'
        ]);

        $order = Order::findOrFail($id);

        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($order->status !== 'completed') {
            return response()->json(['message' => 'Can only review completed orders'], 400);
        }

        if (!$order->driver_id) {
            return response()->json(['message' => 'Pesanan ini tidak memiliki driver, tidak bisa diulas'], 400);
        }

        if (Review::where('order_id', $order->id)->exists()) {
            return response()->json(['message' => 'Order already reviewed'], 400);
        }

        $review = Review::create([
            'order_id' => $order->id,
            'user_id' => $order->user_id,
            'driver_id' => $order->driver_id,
            'rating' => $request->rating,
            'comment' => $request->comment
        ]);

        return response()->json([
            'message' => 'Review submitted successfully',
            'review' => $review
        ], 201);
    }
}
