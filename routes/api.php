<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\OrderController;
use App\Http\Controllers\API\AdminDashboardController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    
    Route::post('/logout', [AuthController::class, 'logout']);

    // Order Routes (Pembeli Mode)
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/my', [OrderController::class, 'myOrders']);
    Route::put('/orders/{id}', [OrderController::class, 'update']);
    Route::delete('/orders/{id}', [OrderController::class, 'destroy']);
    Route::post('/orders/{id}/review', [\App\Http\Controllers\API\ReviewController::class, 'store']);

    // Order Routes (Driver Mode)
    Route::get('/orders/available', [OrderController::class, 'availableOrders']);
    Route::get('/orders/driver/active', [OrderController::class, 'driverActiveOrders']);
    Route::get('/orders/driver/history', [OrderController::class, 'driverHistory']);
    Route::post('/orders/{id}/accept', [OrderController::class, 'acceptOrder']);
    Route::put('/orders/{id}/status', [OrderController::class, 'updateStatus']);
    
    // Admin Routes
    Route::get('/admin/dashboard', [AdminDashboardController::class, 'index']);
    // Users
    Route::get('/admin/users', [AdminDashboardController::class, 'listUsers']);
    Route::put('/admin/users/{id}', [AdminDashboardController::class, 'updateUser']);
    Route::delete('/admin/users/{id}', [AdminDashboardController::class, 'deleteUser']);
    // Orders
    Route::get('/admin/orders', [AdminDashboardController::class, 'listOrders']);
    Route::put('/admin/orders/{id}/status', [AdminDashboardController::class, 'updateOrderStatus']);
    Route::delete('/admin/orders/{id}', [AdminDashboardController::class, 'deleteOrder']);
    // Reviews
    Route::get('/admin/reviews', [AdminDashboardController::class, 'listReviews']);
    Route::delete('/admin/reviews/{id}', [AdminDashboardController::class, 'deleteReview']);
});
