<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();

            // pembeli yang membuat order
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();

            // driver yang mengambil order (null selama masih 'pending')
            $table->foreignId('driver_id')->nullable()->constrained('users')->nullOnDelete();

            $table->string('item_name');
            $table->string('pickup_location');
            $table->string('destination_location');

            $table->decimal('pickup_lat', 10, 7)->nullable();
            $table->decimal('pickup_lng', 10, 7)->nullable();
            $table->decimal('dest_lat', 10, 7)->nullable();
            $table->decimal('dest_lng', 10, 7)->nullable();

            $table->unsignedInteger('fee');
            $table->string('payment_method')->default('Cash');

            // pending -> accepted -> picked_up -> completed (atau cancelled kapan saja)
            $table->string('status')->default('pending');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
