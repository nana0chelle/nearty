<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\User;

class OrderController extends Controller
{
    // Mode Pembeli: Create an order
    public function store(Request $request)
    {
        $request->validate([
            'item_name' => 'required|string',
            'pickup_location' => 'required|string',
            'destination_location' => 'required|string',
            'fee' => 'required|numeric',
            'payment_method' => 'required|string',
            'pickup_lat' => 'nullable|numeric',
            'pickup_lng' => 'nullable|numeric',
            'dest_lat' => 'nullable|numeric',
            'dest_lng' => 'nullable|numeric',
        ]);

        $order = Order::create([
            'user_id' => $request->user()->id,
            'item_name' => $request->item_name,
            'pickup_location' => $request->pickup_location,
            'destination_location' => $request->destination_location,
            'fee' => $request->fee,
            'payment_method' => $request->payment_method,
            'pickup_lat' => $request->pickup_lat,
            'pickup_lng' => $request->pickup_lng,
            'dest_lat' => $request->dest_lat,
            'dest_lng' => $request->dest_lng,
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => 'Order created successfully',
            'order' => $order
        ], 201);
    }

    // Mode Pembeli: Get my active orders
    public function myOrders(Request $request)
    {
        $user = $request->user();
        $orders = Order::where('user_id', $user->id)
            ->with(['driver', 'review'])
            ->orderBy('created_at', 'desc')
            ->get();
        return response()->json($orders);
    }

    // Mode Driver: Get available orders around
    public function availableOrders(Request $request)
    {
        $orders = Order::where('status', 'pending')
                       ->where('user_id', '!=', $request->user()->id)
                       ->get();
        return response()->json($orders);
    }

    // Mode Driver: Get driver active orders (accepted, picked_up)
    public function driverActiveOrders(Request $request)
    {
        $orders = Order::where('driver_id', $request->user()->id)
                       ->whereIn('status', ['accepted', 'picked_up'])
                       ->orderBy('updated_at', 'desc')
                       ->get();
        return response()->json($orders);
    }

    // Mode Driver: Get driver completed orders (history)
    public function driverHistory(Request $request)
    {
        $orders = Order::where('driver_id', $request->user()->id)
                       ->whereIn('status', ['completed', 'cancelled'])
                       ->with('review')
                       ->orderBy('updated_at', 'desc')
                       ->get();
        return response()->json($orders);
    }

    // Mode Driver: Accept an order
    public function acceptOrder(Request $request, $id)
    {
        $order = Order::findOrFail($id);

        if ($order->status !== 'pending') {
            return response()->json(['message' => 'Order is no longer available'], 400);
        }

        if ($order->user_id === $request->user()->id) {
            return response()->json(['message' => 'Cannot accept your own order'], 400);
        }

        $order->update([
            'driver_id' => $request->user()->id,
            'status' => 'accepted'
        ]);

        return response()->json([
            'message' => 'Order accepted',
            'order' => $order
        ]);
    }

    // Mode Driver: Update order status
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:picked_up,completed,cancelled'
        ]);

        $order = Order::findOrFail($id);

        // Only the assigned driver can update the status
        if ($order->driver_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $order->update([
            'status' => $request->status
        ]);

        return response()->json([
            'message' => 'Order status updated',
            'order' => $order
        ]);
    }

    // Mode Pembeli: Update order (only if pending)
    public function update(Request $request, $id)
    {
        $request->validate([
            'item_name' => 'required|string',
            'pickup_location' => 'required|string',
            'destination_location' => 'required|string',
            'pickup_lat' => 'nullable|numeric',
            'pickup_lng' => 'nullable|numeric',
            'dest_lat' => 'nullable|numeric',
            'dest_lng' => 'nullable|numeric',
        ]);

        $order = Order::findOrFail($id);

        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($order->status !== 'pending') {
            return response()->json(['message' => 'Cannot edit order that is already taken or completed'], 400);
        }

        $updateData = [
            'item_name' => $request->item_name,
            'pickup_location' => $request->pickup_location,
            'destination_location' => $request->destination_location,
        ];

        if ($request->has('pickup_lat')) $updateData['pickup_lat'] = $request->pickup_lat;
        if ($request->has('pickup_lng')) $updateData['pickup_lng'] = $request->pickup_lng;
        if ($request->has('dest_lat')) $updateData['dest_lat'] = $request->dest_lat;
        if ($request->has('dest_lng')) $updateData['dest_lng'] = $request->dest_lng;

        $order->update($updateData);

        return response()->json([
            'message' => 'Order updated successfully',
            'order' => $order
        ]);
    }

    // Mode Pembeli: Delete order (only if pending)
    public function destroy(Request $request, $id)
    {
        $order = Order::findOrFail($id);

        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($order->status !== 'pending') {
            return response()->json(['message' => 'Cannot cancel order that is already taken or completed'], 400);
        }

        $order->delete();

        return response()->json([
            'message' => 'Order cancelled successfully'
        ]);
    }
}
