<?php
namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Helpers\LogHelper;

class AdminController extends Controller
{
    // List all users
    public function users(Request $request)
    {
        $this->authorize('admin');
        $users = User::paginate(50);
        return response()->json($users);
    }

    // Update user role
    public function updateUserRole(Request $request, $id)
    {
        $this->authorize('admin');
        $validator = Validator::make($request->all(), [
            'role' => 'required|in:admin,organizer,customer',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        $user = User::findOrFail($id);
        $user->role = $request->role;
        $user->save();
        LogHelper::log($request->user()->id, 'admin_update_role', 'Set user #' . $user->id . ' role to ' . $user->role);
        return response()->json(['user' => $user]);
    }

    // Delete user
    public function deleteUser(Request $request, $id)
    {
        $this->authorize('admin');
        $user = User::findOrFail($id);
        $user->delete();
        LogHelper::log($request->user()->id, 'admin_delete_user', 'Deleted user #' . $id);
        return response()->json(['message' => 'User deleted']);
    }

    // List transactions
    public function transactions(Request $request)
    {
        $this->authorize('admin');
        $query = Transaction::with('user', 'event');
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }
        $transactions = $query->orderBy('created_at', 'desc')->paginate(50);
        return response()->json($transactions);
    }

    // Purge events. If `older_than_days` provided, delete events whose end_time is older.
    public function purgeEvents(Request $request)
    {
        $this->authorize('admin');
        $query = \App\Models\Event::query();
        if ($request->filled('older_than_days')) {
            $days = (int) $request->older_than_days;
            $threshold = now()->subDays($days);
            $query->where('end_time', '<', $threshold);
        }
        $count = $query->delete();
        LogHelper::log($request->user()->id, 'admin_purge_events', 'Purged events count: ' . $count);
        return response()->json(['deleted' => $count]);
    }

    // List organizers
    public function organizers(Request $request)
    {
        $this->authorize('admin');
        $data = \App\Models\Organizer::with('user')->paginate(50);
        return response()->json($data);
    }

    // Update organizer profile
    public function updateOrganizer(Request $request, $id)
    {
        $this->authorize('admin');
        $org = \App\Models\Organizer::findOrFail($id);
        $org->update($request->only(['organization_name','address','contact_person','contact_phone']));
        LogHelper::log($request->user()->id, 'admin_update_organizer', 'Updated organizer #' . $id);
        return response()->json(['organizer' => $org]);
    }

    // Delete organizer (and optionally their events)
    public function deleteOrganizer(Request $request, $id)
    {
        $this->authorize('manage', \App\Models\Organizer::class);
        $org = \App\Models\Organizer::with('events.ticketCategories.tickets')->findOrFail($id);

        // Soft-delete cascade: delete tickets -> categories -> events
        foreach ($org->events as $event) {
            foreach ($event->ticketCategories as $cat) {
                // delete tickets
                foreach ($cat->tickets as $t) {
                    $t->delete();
                }
                $cat->delete();
            }
            $event->delete();
        }

        // Soft-delete organizer itself
        $org->delete();
        LogHelper::log($request->user()->id, 'admin_delete_organizer', 'Deleted organizer #' . $id);
        return response()->json(['message' => 'Organizer deleted']);
    }
}
