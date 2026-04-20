<?php
namespace App\Policies;

use App\Models\User;

class AdminPolicy
{
    /**
     * Determine whether the user can perform admin actions.
     */
    public function manage(User $user): bool
    {
        return $user && $user->role === 'admin';
    }
}
