<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create Admin
        \App\Models\User::factory()->create([
            'name' => 'Admin Nearty',
            'email' => 'admin@nearty.com',
            'password' => bcrypt('password'),
            'role' => 'admin',
        ]);

        // Create Pembeli
        $pembeli = \App\Models\User::factory()->create([
            'name' => 'Siti Pembeli',
            'email' => 'siti@nearty.com',
            'password' => bcrypt('password'),
            'role' => 'user',
        ]);

        // Create Driver
        $driver = \App\Models\User::factory()->create([
            'name' => 'Budi Driver',
            'email' => 'budi@nearty.com',
            'password' => bcrypt('password'),
            'role' => 'user',
            'is_driver_online' => true,
        ]);

        // Create Pending Orders
        \App\Models\Order::create([
            'user_id' => $pembeli->id,
            'item_name' => 'Kopi Kenangan, 2 Cup',
            'pickup_location' => 'Gedung A',
            'destination_location' => 'Kost B',
            'fee' => 15000,
            'status' => 'pending',
        ]);

        \App\Models\Order::create([
            'user_id' => $pembeli->id,
            'item_name' => 'Nasi Goreng Spesial',
            'pickup_location' => 'Warung Depan',
            'destination_location' => 'Kost B',
            'fee' => 12000,
            'status' => 'pending',
        ]);
    }
}
