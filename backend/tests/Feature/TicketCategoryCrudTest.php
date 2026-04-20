<?php
namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\User;
use App\Models\Organizer;
use App\Models\Event;
use App\Models\TicketCategory;

class TicketCategoryCrudTest extends TestCase
{
    use RefreshDatabase;

    public function test_crud_ticket_category_by_organizer()
    {
        $user = User::factory()->create(['role' => 'organizer']);
        $org = Organizer::create(['user_id' => $user->id, 'organization_name' => 'Org', 'address' => 'Addr', 'contact_person' => $user->name, 'contact_phone' => '081234']);

        $event = Event::create([
            'organizer_id' => $org->id,
            'title' => 'E',
            'description' => 'D',
            'location' => 'L',
            'start_time' => now()->addDay(),
            'end_time' => now()->addDays(2),
            'status' => 'draft',
        ]);

        // Create
        $resp = $this->actingAs($user, 'sanctum')->postJson("/api/organizer/events/{$event->id}/ticket-categories", [
            'name' => 'VIP', 'price' => 100.00, 'quota' => 50
        ]);
        $resp->assertStatus(201);
        $this->assertDatabaseHas('ticket_categories', ['name' => 'VIP', 'event_id' => $event->id]);

        $catId = $resp->json('id');

        // Update
        $u = $this->actingAs($user, 'sanctum')->putJson("/api/organizer/events/{$event->id}/ticket-categories/{$catId}", ['price' => 120]);
        $u->assertStatus(200);
        $this->assertDatabaseHas('ticket_categories', ['id' => $catId, 'price' => 120]);

        // Delete
        $d = $this->actingAs($user, 'sanctum')->deleteJson("/api/organizer/events/{$event->id}/ticket-categories/{$catId}");
        $d->assertStatus(200);
        $this->assertSoftDeleted('ticket_categories', ['id' => $catId]);
    }
}
