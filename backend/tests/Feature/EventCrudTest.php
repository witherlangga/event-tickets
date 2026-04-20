<?php
namespace Tests\Feature;

use App\Models\User;
use App\Models\Organizer;
use App\Models\Event;
use App\Models\TicketCategory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EventCrudTest extends TestCase
{
    use RefreshDatabase;

    public function test_organizer_can_create_update_delete_event()
    {
        $organizerUser = User::factory()->create(['role' => 'organizer']);
        $organizer = Organizer::create([
            'user_id' => $organizerUser->id,
            'organization_name' => 'Test Org',
            'address' => 'Jl. Test',
            'contact_person' => 'Test',
            'contact_phone' => '0812345678',
        ]);
        $organizerUser->refresh(); // pastikan relasi organizer ter-load
        $token = $organizerUser->createToken('test')->plainTextToken;

        // Create event
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/events', [
                'title' => 'Event Test',
                'description' => 'Deskripsi',
                'location' => 'Lokasi',
                'start_time' => now()->addDay(),
                'end_time' => now()->addDays(2),
            ]);
        $response->assertStatus(201);
        $eventId = $response->json('id');

        // Update event
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->putJson('/api/events/' . $eventId, [
                'title' => 'Event Updated',
            ]);
        $response->assertStatus(200);
        $this->assertEquals('Event Updated', $response->json('title'));

        // Delete event
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->deleteJson('/api/events/' . $eventId);
        $response->assertStatus(200);
    }

    public function test_organizer_can_crud_ticket_category()
    {
        $organizerUser = User::factory()->create(['role' => 'organizer']);
        $organizer = Organizer::create([
            'user_id' => $organizerUser->id,
            'organization_name' => 'Test Org',
            'address' => 'Jl. Test',
            'contact_person' => 'Test',
            'contact_phone' => '0812345678',
        ]);
        $organizerUser->refresh(); // pastikan relasi organizer ter-load
        $token = $organizerUser->createToken('test')->plainTextToken;
        $event = Event::create([
            'organizer_id' => $organizer->id,
            'title' => 'Event Test',
            'description' => 'Deskripsi',
            'location' => 'Lokasi',
            'start_time' => now()->addDay(),
            'end_time' => now()->addDays(2),
            'status' => 'draft',
        ]);

        // Create category
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/events/' . $event->id . '/categories', [
                'name' => 'VIP',
                'price' => 100000,
                'quota' => 10,
            ]);
        $response->assertStatus(201);
        $categoryId = $response->json('id');

        // Update category
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->putJson('/api/events/' . $event->id . '/categories/' . $categoryId, [
                'price' => 200000,
            ]);
        $response->assertStatus(200);
        $this->assertEquals(200000, $response->json('price'));

        // Delete category
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->deleteJson('/api/events/' . $event->id . '/categories/' . $categoryId);
        $response->assertStatus(200);
    }
}
