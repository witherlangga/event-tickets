<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use App\Models\Event;
use App\Models\TicketCategory;

class CustomerBookingFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_book_and_view_tickets()
    {
        Storage::fake('public');

        // Create organizer + event + ticket category
        $organizer = User::factory()->create(['role' => 'organizer']);
        $organizer->organizer()->create(['organization_name' => 'Org','address' => 'Addr','contact_person' => $organizer->name,'contact_phone' => '123']);

        $event = Event::create([
            'organizer_id' => $organizer->organizer->id,
            'title' => 'Sample',
            'description' => 'Desc',
            'location' => 'Loc',
            'start_time' => now()->addDay(),
            'end_time' => now()->addDays(2),
            'status' => 'published'
        ]);

        $category = TicketCategory::create([
            'event_id' => $event->id,
            'name' => 'General',
            'price' => 10000,
            'quota' => 100,
            'sold' => 0,
        ]);

        // Register customer and get token
        $reg = $this->postJson('/api/register/customer', [
            'name' => 'Buyer',
            'email' => 'buyer@example.test',
            'password' => 'Password1',
        ]);
        $token = $reg->json('token');

        // Book ticket
        $bookResp = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/book', [
                'event_id' => $event->id,
                'ticket_category_id' => $category->id,
                'quantity' => 1,
            ]);

        $bookResp->assertStatus(201)->assertJsonStructure(['message','transaction_id']);

        // Check my tickets
        $my = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/my-tickets');

        $my->assertStatus(200)->assertJsonCount(1, 'data');
    }
}
