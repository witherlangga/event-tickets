<?php
namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;
use App\Models\Event;
use App\Policies\EventPolicy;
use App\Policies\AdminPolicy;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Organizer;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        Event::class => EventPolicy::class,
        User::class => AdminPolicy::class,
        Transaction::class => AdminPolicy::class,
        Organizer::class => AdminPolicy::class,
    ];

    public function boot(): void
    {
        $this->registerPolicies();
        // Simple admin gate used across controllers
        Gate::define('admin', function (User $user) {
            return $user->role === 'admin';
        });
    }
}
