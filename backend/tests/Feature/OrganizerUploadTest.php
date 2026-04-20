<?php
namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use App\Models\Organizer;

class OrganizerUploadTest extends TestCase
{
    use RefreshDatabase;

    public function test_organizer_can_upload_banner_when_creating_event()
    {
        Storage::fake('public');

        $user = User::factory()->create(['role' => 'organizer']);
        Organizer::create(['user_id' => $user->id, 'organization_name' => 'Org', 'address' => 'Addr', 'contact_person' => $user->name, 'contact_phone' => '081234']);

        $file = UploadedFile::fake()->image('banner.jpg');

        $response = $this->actingAs($user, 'sanctum')->post('/api/organizer/events', [
            'title' => 'Event X',
            'description' => 'Desc',
            'location' => 'City',
            'start_time' => now()->addDays(5)->toDateTimeString(),
            'end_time' => now()->addDays(6)->toDateTimeString(),
            'banner' => $file,
        ]);

        $response->assertStatus(201);
        $data = $response->json();
        $this->assertArrayHasKey('banner', $data);
        $this->assertTrue(Storage::disk('public')->exists($data['banner']));
    }
}
