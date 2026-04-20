<?php
namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\TicketCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Helpers\LogHelper;

class TicketCategoryController extends Controller
{
    // Public list
    public function index($event_id)
    {
        $event = Event::findOrFail($event_id);
        $categories = TicketCategory::where('event_id', $event->id)->get();
        return response()->json(['categories' => $categories]);
    }

    // Organizer create
    public function store(Request $request, $event_id)
    {
        $event = Event::findOrFail($event_id);
        $this->authorize('update', $event);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string',
            'price' => 'required|numeric|min:0',
            'quota' => 'required|integer|min:0',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $payload = $validator->validated();
        $payload['event_id'] = $event->id;

        $category = TicketCategory::create($payload);
        if (class_exists(LogHelper::class)) {
            LogHelper::log($request->user()->id, 'ticket_category_create', 'Create category #' . $category->id . ' for event #' . $event->id);
        }
        return response()->json(['category' => $category], 201);
    }

    // Organizer update
    public function update(Request $request, $event_id, $id)
    {
        $event = Event::findOrFail($event_id);
        $this->authorize('update', $event);

        $category = TicketCategory::where('event_id', $event->id)->findOrFail($id);
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string',
            'price' => 'sometimes|numeric|min:0',
            'quota' => 'sometimes|integer|min:0',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        $category->update($validator->validated());
        if (class_exists(LogHelper::class)) {
            LogHelper::log($request->user()->id, 'ticket_category_update', 'Update category #' . $category->id);
        }
        return response()->json(['category' => $category]);
    }

    // Organizer delete
    public function destroy(Request $request, $event_id, $id)
    {
        $event = Event::findOrFail($event_id);
        $this->authorize('update', $event);

        $category = TicketCategory::where('event_id', $event->id)->findOrFail($id);
        $category->delete();
        if (class_exists(LogHelper::class)) {
            LogHelper::log($request->user()->id, 'ticket_category_delete', 'Delete category #' . $id);
        }
        return response()->json(['message' => 'Category deleted']);
    }
}