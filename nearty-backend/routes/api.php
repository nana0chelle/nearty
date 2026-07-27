<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OrderController;
use Illuminate\Support\Facades\Route;

// ========== AUTH (public) ==========
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// ========== ORDERS (perlu login) ==========
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orders/my', [OrderController::class, 'my']);
    Route::get('/orders/available', [OrderController::class, 'available']);
    Route::get('/orders/driver/active', [OrderController::class, 'driverActive']);
    Route::get('/orders/driver/history', [OrderController::class, 'driverHistory']);

    Route::post('/orders', [OrderController::class, 'store']);
    Route::put('/orders/{order}', [OrderController::class, 'update']);
    Route::delete('/orders/{order}', [OrderController::class, 'destroy']);

    Route::post('/orders/{order}/accept', [OrderController::class, 'accept']);
    Route::put('/orders/{order}/status', [OrderController::class, 'updateStatus']);
    Route::post('/orders/{order}/review', [OrderController::class, 'review']);

    // ========== ADMIN (perlu login + role admin) ==========
    Route::middleware('admin')->prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminController::class, 'dashboard']);

        Route::get('/users', [AdminController::class, 'users']);
        Route::put('/users/{user}', [AdminController::class, 'updateUserRole']);
        Route::delete('/users/{user}', [AdminController::class, 'deleteUser']);

        Route::get('/orders', [AdminController::class, 'orders']);
        Route::put('/orders/{order}/status', [AdminController::class, 'updateOrderStatus']);
        Route::delete('/orders/{order}', [AdminController::class, 'deleteOrder']);

        Route::get('/reviews', [AdminController::class, 'reviews']);
        Route::delete('/reviews/{review}', [AdminController::class, 'deleteReview']);
    });
});
