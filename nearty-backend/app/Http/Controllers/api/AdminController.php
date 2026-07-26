<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Review;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminController extends Controller
{
    // ========== DASHBOARD ==========
    // GET /api/admin/dashboard
    public function dashboard()
    {
        return response()->json([
            'total_users' => User::count(),
            'total_orders' => Order::count(),
            'active_orders' => Order::whereIn('status', ['pending', 'accepted', 'picked_up'])->count(),
            'total_revenue' => Order::where('status', 'completed')->sum('fee'),
            'recent_orders' => Order::with('user')->latest()->take(5)->get(),
        ]);
    }

    // ========== USERS ==========
    // GET /api/admin/users
    public function users()
    {
        return response()->json(User::latest()->get());
    }

    // PUT /api/admin/users/{id}
    public function updateUserRole(Request $request, User $user)
    {
        $validator = Validator::make($request->all(), [
            'role' => ['required', 'string', 'in:user,driver,admin'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Gagal memperbarui role'], 422);
        }

        $user->update(['role' => $request->role]);

        return response()->json($user);
    }

    // DELETE /api/admin/users/{id}
    public function deleteUser(User $user)
    {
        $user->delete();

        return response()->json(['message' => 'Pengguna dihapus']);
    }

    // ========== ORDERS ==========
    // GET /api/admin/orders
    public function orders()
    {
        return response()->json(
            Order::with(['user', 'driver', 'review'])->latest()->get()
        );
    }

    // PUT /api/admin/orders/{id}/status
    public function updateOrderStatus(Request $request, Order $order)
    {
        $validator = Validator::make($request->all(), [
            'status' => ['required', 'string', 'in:pending,accepted,picked_up,completed,cancelled'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Gagal memperbarui status'], 422);
        }

        $order->update(['status' => $request->status]);

        return response()->json($order->fresh(['user', 'driver']));
    }

    // DELETE /api/admin/orders/{id}
    public function deleteOrder(Order $order)
    {
        $order->delete();

        return response()->json(['message' => 'Pesanan dihapus']);
    }

    // ========== REVIEWS ==========
    // GET /api/admin/reviews
    public function reviews()
    {
        return response()->json(
            Review::with('order.user')->latest()->get()
        );
    }

    // DELETE /api/admin/reviews/{id}
    public function deleteReview(Review $review)
    {
        $review->delete();

        return response()->json(['message' => 'Ulasan dihapus']);
    }
}
