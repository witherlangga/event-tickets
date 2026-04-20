<?php
namespace App\Http\Controllers;

use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Helpers\LogHelper;

class EventController extends Controller
{
    // List event (semua role)
    public function index(Request $request)
    {
        $events = Event::with('ticketCategories')->get();
        return response()->json($events);
    }

    // Buat event (organizer)
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string',
            'description' => 'required|string',
            'location' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'start_time' => 'required|date',
            'end_time' => 'required|date|after_or_equal:start_time',
            'banner' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        $organizer = $request->user()->organizer;
        $event = Event::create(array_merge($validator->validated(), [
            'organizer_id' => $organizer->id,
            'status' => 'draft',
        ]));
        LogHelper::log($request->user()->id, 'event_create', 'Membuat event #' . $event->id);
        return response()->json($event, 201);
    }

    // Update event (organizer)
    public function update(Request $request, $id)
    {
        $event = Event::findOrFail($id);
        $this->authorize('update', $event); // Policy bisa ditambah
        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|string',
            'description' => 'sometimes|string',
            'location' => 'sometimes|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'start_time' => 'sometimes|date',
            'end_time' => 'sometimes|date|after_or_equal:start_time',
            'banner' => 'nullable|string',
            'status' => 'sometimes|in:draft,published,cancelled',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        $event->update($validator->validated());
        LogHelper::log($request->user()->id, 'event_update', 'Update event #' . $event->id);
        return response()->json($event);
    }

    // Hapus event (organizer)
    public function destroy(Request $request, $id)
    {
        $event = Event::findOrFail($id);
        $this->authorize('delete', $event); // Policy bisa ditambah
        $event->delete();
        LogHelper::log($request->user()->id, 'event_delete', 'Hapus event #' . $id);
        return response()->json(['message' => 'Event deleted']);
    }
}
