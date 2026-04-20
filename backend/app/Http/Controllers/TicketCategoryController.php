<?php
namespace App\Http\Controllers;

use App\Models\TicketCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Helpers\LogHelper;

class TicketCategoryController extends Controller
{
    // List kategori tiket untuk event tertentu
    public function index(Request $request, $eventId)
    {
        $categories = TicketCategory::where('event_id', $eventId)->get();
        return response()->json($categories);
    }

    // Buat kategori tiket (organizer)
    public function store(Request $request, $eventId)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string',
            'price' => 'required|numeric|min:0',
            'quota' => 'required|integer|min:1',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        $category = TicketCategory::create(array_merge($validator->validated(), [
            'event_id' => $eventId,
        ]));
        LogHelper::log($request->user()->id, 'ticket_category_create', 'Buat kategori tiket #' . $category->id . ' untuk event #' . $eventId);
        return response()->json($category, 201);
    }

    // Update kategori tiket (organizer)
    public function update(Request $request, $eventId, $id)
    {
        $category = TicketCategory::where('event_id', $eventId)->findOrFail($id);
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string',
            'price' => 'sometimes|numeric|min:0',
            'quota' => 'sometimes|integer|min:1',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        $category->update($validator->validated());
        LogHelper::log($request->user()->id, 'ticket_category_update', 'Update kategori tiket #' . $id . ' untuk event #' . $eventId);
        return response()->json($category);
    }

    // Hapus kategori tiket (organizer)
    public function destroy(Request $request, $eventId, $id)
    {
        $category = TicketCategory::where('event_id', $eventId)->findOrFail($id);
        $category->delete();
        LogHelper::log($request->user()->id, 'ticket_category_delete', 'Hapus kategori tiket #' . $id . ' untuk event #' . $eventId);
        return response()->json(['message' => 'Kategori tiket dihapus']);
    }
}
