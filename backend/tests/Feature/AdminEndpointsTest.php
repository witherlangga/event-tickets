<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\User;
use App\Models\Transaction;

class AdminEndpointsTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_manage_users_and_view_transactions()
    {
        // Create admin user
        $admin = User::factory()->create(['role' => 'admin']);

        // Create other users
        $userA = User::factory()->create(['role' => 'customer']);
        $userB = User::factory()->create(['role' => 'customer']);

        // Create an organizer + event to attach transactions
        $organizer = User::factory()->create(['role' => 'organizer']);
        $organizer->organizer()->create(['organization_name' => 'Org','address' => 'Addr','contact_person' => $organizer->name,'contact_phone' => '123']);
        $event = \App\Models\Event::create([
            'organizer_id' => $organizer->organizer->id,
            'title' => 'Admin Event',
            'description' => 'desc',
            'location' => 'loc',
            'start_time' => now()->addDay(),
            'end_time' => now()->addDays(2),
            'status' => 'published'
        ]);

        // Create some transactions
        Transaction::create([
            'user_id' => $userA->id,
            'event_id' => $event->id,
            'total_amount' => 5000,
            'status' => 'paid',
        ]);
        Transaction::create([
            'user_id' => $userB->id,
            'event_id' => $event->id,
            'total_amount' => 10000,
            'status' => 'pending',
        ]);

        $token = $admin->createToken('test')->plainTextToken;

        // List users
        $list = $this->withHeader('Authorization', 'Bearer ' . $token)->getJson('/api/admin/users');
        $list->assertStatus(200)->assertJsonStructure(['data']);

        // Update role
        $upd = $this->withHeader('Authorization', 'Bearer ' . $token)->putJson('/api/admin/users/' . $userA->id . '/role', ['role' => 'organizer']);
        $upd->assertStatus(200)->assertJsonPath('user.role', 'organizer');

        // Delete user B
        $del = $this->withHeader('Authorization', 'Bearer ' . $token)->deleteJson('/api/admin/users/' . $userB->id);
        $del->assertStatus(200)->assertJson(['message' => 'User deleted']);

        // List transactions
        $tx = $this->withHeader('Authorization', 'Bearer ' . $token)->getJson('/api/admin/transactions');
        $tx->assertStatus(200)->assertJsonStructure(['data']);

        // Purge events (no filter) - should delete at least 1
        $purge = $this->withHeader('Authorization', 'Bearer ' . $token)->postJson('/api/admin/events/purge');
        $purge->assertStatus(200)->assertJsonStructure(['deleted']);

        // Organizer management
        $orgs = $this->withHeader('Authorization', 'Bearer ' . $token)->getJson('/api/admin/organizers');
        $orgs->assertStatus(200)->assertJsonStructure(['data']);

        $orgId = $organizer->organizer->id;
        $updOrg = $this->withHeader('Authorization', 'Bearer ' . $token)->putJson('/api/admin/organizers/' . $orgId, ['organization_name' => 'New Org']);
        $updOrg->assertStatus(200)->assertJsonPath('organizer.organization_name', 'New Org');

        $delOrg = $this->withHeader('Authorization', 'Bearer ' . $token)->deleteJson('/api/admin/organizers/' . $orgId);
        $delOrg->assertStatus(200)->assertJson(['message' => 'Organizer deleted']);
    }
}
