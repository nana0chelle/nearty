<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class OrderController extends Controller
{
    // GET /api/orders/my  (pesanan milik pembeli yang login)
    public function my(Request $request)
    {
        $orders = Order::with('review')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json($orders);
    }

    // GET /api/orders/available  (pesanan pending yang belum diambil driver manapun)
    public function available(Request $request)
    {
        $orders = Order::whereNull('driver_id')
            ->where('status', 'pending')
            ->latest()
            ->get();

        return response()->json($orders);
    }

    // GET /api/orders/driver/active  (pesanan yang sedang dijalani driver)
    public function driverActive(Request $request)
    {
        $orders = Order::where('driver_id', $request->user()->id)
            ->whereIn('status', ['accepted', 'picked_up'])
            ->latest()
            ->get();

        return response()->json($orders);
    }

    // GET /api/orders/driver/history
    public function driverHistory(Request $request)
    {
        $orders = Order::with('review')
            ->where('driver_id', $request->user()->id)
            ->whereIn('status', ['completed', 'cancelled'])
            ->latest()
            ->get();

        return response()->json($orders);
    }

    // POST /api/orders
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'item_name' => ['required', 'string', 'max:255'],
            'pickup_location' => ['required', 'string', 'max:255'],
            'destination_location' => ['required', 'string', 'max:255'],
            'fee' => ['required', 'integer', 'min:0'],
            'payment_method' => ['nullable', 'string', 'max:50'],
            'pickup_lat' => ['nullable', 'numeric'],
            'pickup_lng' => ['nullable', 'numeric'],
            'dest_lat' => ['nullable', 'numeric'],
            'dest_lng' => ['nullable', 'numeric'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Gagal membuat pesanan', 'errors' => $validator->errors()], 422);
        }

        $order = Order::create([
            'user_id' => $request->user()->id,
            'item_name' => $request->item_name,
            'pickup_location' => $request->pickup_location,
            'destination_location' => $request->destination_location,
            'fee' => $request->fee,
            'payment_method' => $request->payment_method ?? 'Cash',
            'pickup_lat' => $request->pickup_lat,
            'pickup_lng' => $request->pickup_lng,
            'dest_lat' => $request->dest_lat,
            'dest_lng' => $request->dest_lng,
            'status' => 'pending',
        ]);

        return response()->json($order, 201);
    }

    // PUT /api/orders/{id}  (hanya pemilik pesanan, selama masih pending)
    public function update(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Gagal memperbarui pesanan'], 403);
        }

        $order->update($request->only(['item_name', 'pickup_location', 'destination_location']));

        return response()->json($order);
    }

    // DELETE /api/orders/{id}  (pembeli membatalkan pesanan miliknya -> soft cancel)
    public function destroy(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Gagal membatalkan pesanan'], 403);
        }

        $order->update(['status' => 'cancelled']);

        return response()->json(['message' => 'Pesanan dibatalkan']);
    }

    // POST /api/orders/{id}/accept  (driver mengambil pesanan)
    public function accept(Request $request, Order $order)
    {
        if ($order->status !== 'pending' || $order->driver_id !== null) {
            return response()->json(['message' => 'Gagal mengambil pesanan'], 409);
        }

        $order->update([
            'driver_id' => $request->user()->id,
            'status' => 'accepted',
        ]);

        return response()->json(['order' => $order->fresh()]);
    }

    // PUT /api/orders/{id}/status  (driver update status: picked_up / completed)
    public function updateStatus(Request $request, Order $order)
    {
        $validator = Validator::make($request->all(), [
            'status' => ['required', 'string', 'in:pending,accepted,picked_up,completed,cancelled'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Status tidak valid'], 422);
        }

        if ($order->driver_id !== $request->user()->id) {
            return response()->json(['message' => 'Gagal memperbarui status'], 403);
        }

        $order->update(['status' => $request->status]);

        return response()->json($order->fresh());
    }

    // POST /api/orders/{id}/review
    public function review(Request $request, Order $order)
    {
        $validator = Validator::make($request->all(), [
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string', 'max:1000'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Gagal mengirim ulasan'], 422);
        }

        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Gagal mengirim ulasan'], 403);
        }

        $review = $order->review()->updateOrCreate(
            ['order_id' => $order->id],
            ['rating' => $request->rating, 'comment' => $request->comment]
        );

        return response()->json($review, 201);
    }
}
