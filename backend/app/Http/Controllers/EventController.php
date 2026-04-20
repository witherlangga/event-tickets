<?php
namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\Organizer;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index()
    {
        // Hanya tampilkan event yang statusnya 'published' di dashboard publik
        $events = Event::with('organizer')
            ->where('status', 'published')
            ->latest()
            ->get();
        return response()->json(['events' => $events]);
    }

    public function show($id)
    {
        $event = Event::with('ticketCategories')->findOrFail($id);
        return response()->json(['event' => $event]);
    }

    // Events belonging to authenticated organizer
    public function organizerIndex(Request $request)
    {
        $user = $request->user();
        $organizer = Organizer::where('user_id', $user->id)->firstOrFail();
        $events = Event::where('organizer_id', $organizer->id)->with('ticketCategories')->get();
        return response()->json(['events' => $events]);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        $organizer = Organizer::where('user_id', $user->id)->firstOrFail();

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'location' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'start_time' => 'required|date',
            'end_time' => 'required|date|after_or_equal:start_time',
            'banner' => 'nullable|image|max:4096',
            'status' => 'nullable|in:draft,published,cancelled',
        ]);

        if ($request->hasFile('banner')) {
            $path = $request->file('banner')->store('banners', 'public');
            $data['banner'] = $path;
        }

        $data['organizer_id'] = $organizer->id;
        $data['status'] = $data['status'] ?? 'draft';

        $event = Event::create($data);

        return response()->json(['event' => $event], 201);
    }

    public function update(Request $request, $id)
    {
        $user = $request->user();
        $organizer = Organizer::where('user_id', $user->id)->firstOrFail();
        $event = Event::where('organizer_id', $organizer->id)->findOrFail($id);

        $data = $request->validate([
            'title' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'location' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'start_time' => 'nullable|date',
            'end_time' => 'nullable|date',
            'banner' => 'nullable|image|max:4096',
            'status' => 'nullable|in:draft,published,cancelled',
        ]);

        if ($request->hasFile('banner')) {
            $path = $request->file('banner')->store('banners', 'public');
            $data['banner'] = $path;
        }

        $event->update($data);
        return response()->json(['event' => $event]);
    }

    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $organizer = Organizer::where('user_id', $user->id)->firstOrFail();
        $event = Event::where('organizer_id', $organizer->id)->findOrFail($id);
        $event->delete();
        return response()->json(['message' => 'Event deleted']);
    }

    public function publish(Request $request, $id)
    {
        $user = $request->user();
        $organizer = Organizer::where('user_id', $user->id)->firstOrFail();
        $event = Event::where('organizer_id', $organizer->id)->findOrFail($id);
        $event->status = 'published';
        $event->save();
        return response()->json(['event' => $event]);
    }
}
