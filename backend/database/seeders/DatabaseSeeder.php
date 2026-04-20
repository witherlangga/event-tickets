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
        // Admin
        User::factory()->create([
            'name' => 'Admin',
            'email' => 'admin@example.com',
            'password' => \Illuminate\Support\Facades\Hash::make('password'),
            'role' => 'admin',
        ]);

        // Organizer
        $organizerUser = User::factory()->create([
            'name' => 'Organizer',
            'email' => 'organizer@example.com',
            'password' => \Illuminate\Support\Facades\Hash::make('password'),
            'role' => 'organizer',
        ]);
        $organizer = \App\Models\Organizer::create([
            'user_id' => $organizerUser->id,
            'organization_name' => 'Event Org',
            'address' => 'Jl. Raya No.1',
            'contact_person' => 'Budi',
            'contact_phone' => '08123456789',
        ]);

        // Customer
        $customer = User::factory()->create([
            'name' => 'Customer',
            'email' => 'customer@example.com',
            'password' => \Illuminate\Support\Facades\Hash::make('password'),
            'role' => 'customer',
        ]);

        // Event
        $event = \App\Models\Event::create([
            'organizer_id' => $organizer->id,
            'title' => 'Music Fest',
            'description' => 'Festival Musik Terbesar',
            'location' => 'Lapangan Merdeka',
            'latitude' => -8.5830695,
            'longitude' => 116.3202515,
            'start_time' => now()->addDays(10),
            'end_time' => now()->addDays(11),
            'status' => 'published',
        ]);

        // Ticket Categories
        \App\Models\TicketCategory::create([
            'event_id' => $event->id,
            'name' => 'VIP',
            'price' => 500000,
            'quota' => 50,
        ]);
        \App\Models\TicketCategory::create([
            'event_id' => $event->id,
            'name' => 'Reguler',
            'price' => 150000,
            'quota' => 200,
        ]);
    }
}
