<?php
namespace App\Policies;

use App\Models\Event;
use App\Models\User;

class EventPolicy
{
    public function view(?User $user, Event $event): bool
    {
        // Public: siapa saja bisa lihat event yang dipublish
        if ($event->status === 'published') {
            return true;
        }
        // Organizer yang memiliki event atau admin dapat melihat draft/cancelled
        if ($user && $user->role === 'admin') {
            return true;
        }
        if ($user && $user->role === 'organizer' && $user->organizer && $event->organizer_id === $user->organizer->id) {
            return true;
        }
        return false;
    }

    public function create(User $user): bool
    {
        return $user->role === 'organizer';
    }

    public function update(User $user, Event $event): bool
    {
        return $user->role === 'organizer' && $user->organizer && $event->organizer_id === $user->organizer->id;
    }

    public function delete(User $user, Event $event): bool
    {
        return $this->update($user, $event);
    }

    public function publish(User $user, Event $event): bool
    {
        // Only organizer owner or admin
        if ($user->role === 'admin') return true;
        return $user->role === 'organizer' && $user->organizer && $event->organizer_id === $user->organizer->id;
    }
}
