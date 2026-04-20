<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\User;

class CustomerAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_and_login_customer()
    {
        // Register customer
        $resp = $this->postJson('/api/register/customer', [
            'name' => 'Test Customer',
            'email' => 'customer@example.test',
            'password' => 'Password1',
        ]);

        $resp->assertStatus(201)->assertJsonStructure(['user' => ['id','email','role'], 'token']);
        $this->assertEquals('customer', $resp->json('user.role'));

        // Login via customer endpoint
        $login = $this->postJson('/api/login/customer', [
            'email' => 'customer@example.test',
            'password' => 'Password1',
        ]);
        $login->assertStatus(200)->assertJsonStructure(['user' => ['id','email','role'], 'token']);
        $this->assertEquals('customer', $login->json('user.role'));
    }
}
