<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\User;
use App\Models\Review;

class AdminDashboardController extends Controller
{
    private function checkAdmin(Request $request)
    {
        return $request->user()->role === 'admin';
    }

    // ========== DASHBOARD ==========
    public function index(Request $request)
    {
        if (!$this->checkAdmin($request)) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $totalUsers = User::where('role', '!=', 'admin')->count();
        $totalOrders = Order::count();
        $activeOrders = Order::whereIn('status', ['pending', 'accepted', 'picked_up'])->count();
        $totalRevenue = Order::where('status', 'completed')->sum('fee');

        $recentOrders = Order::with(['user', 'driver'])
            ->orderBy('created_at', 'desc')
            ->take(10)
            ->get();

        return response()->json([
            'total_users'   => $totalUsers,
            'total_orders'  => $totalOrders,
            'active_orders' => $activeOrders,
            'total_revenue' => $totalRevenue,
            'recent_orders' => $recentOrders,
        ]);
    }

    // ========== USERS ==========
    public function listUsers(Request $request)
    {
        if (!$this->checkAdmin($request)) return response()->json(['message' => 'Unauthorized'], 403);

        $users = User::orderBy('created_at', 'desc')->get();
        return response()->json($users);
    }

    public function updateUser(Request $request, $id)
    {
        if (!$this->checkAdmin($request)) return response()->json(['message' => 'Unauthorized'], 403);

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'role' => 'sometimes|in:user,admin',
        ]);

        $user = User::findOrFail($id);
        $user->update($request->only(['name', 'role']));

        return response()->json(['message' => 'User updated successfully', 'user' => $user]);
    }

    public function deleteUser(Request $request, $id)
    {
        if (!$this->checkAdmin($request)) return response()->json(['message' => 'Unauthorized'], 403);

        $user = User::findOrFail($id);
        if ($user->role === 'admin') {
            return response()->json(['message' => 'Cannot delete admin account'], 403);
        }
        $user->delete();

        return response()->json(['message' => 'User deleted successfully']);
    }

    // ========== ORDERS ==========
    public function listOrders(Request $request)
    {
        if (!$this->checkAdmin($request)) return response()->json(['message' => 'Unauthorized'], 403);

        $orders = Order::with(['user', 'driver'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($orders);
    }

    public function updateOrderStatus(Request $request, $id)
    {
        if (!$this->checkAdmin($request)) return response()->json(['message' => 'Unauthorized'], 403);

        $request->validate([
            'status' => 'required|in:pending,accepted,picked_up,completed,cancelled',
        ]);

        $order = Order::findOrFail($id);
        $order->update(['status' => $request->status]);

        return response()->json(['message' => 'Order status updated', 'order' => $order]);
    }

    public function deleteOrder(Request $request, $id)
    {
        if (!$this->checkAdmin($request)) return response()->json(['message' => 'Unauthorized'], 403);

        $order = Order::findOrFail($id);
        $order->delete();

        return response()->json(['message' => 'Order deleted successfully']);
    }

    // ========== REVIEWS ==========
    public function listReviews(Request $request)
    {
        if (!$this->checkAdmin($request)) return response()->json(['message' => 'Unauthorized'], 403);

        $reviews = Review::with(['user:id,name,email', 'order:id,item_name,user_id'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($reviews);
    }

    public function deleteReview(Request $request, $id)
    {
        if (!$this->checkAdmin($request)) return response()->json(['message' => 'Unauthorized'], 403);

        $review = Review::findOrFail($id);
        $review->delete();

        return response()->json(['message' => 'Review deleted successfully']);
    }
}
