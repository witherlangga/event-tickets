<?php
namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\Ticket;
use App\Models\TicketCategory;
use App\Models\Transaction;
use App\Models\TransactionDetail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use App\Jobs\AutoCancelUnpaidBooking;
use App\Jobs\SendTicketEmail;
use App\Helpers\LogHelper;

class BookingController extends Controller
{
    public function book(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'event_id' => 'required|exists:events,id',
            'ticket_category_id' => 'required|exists:ticket_categories,id',
            'quantity' => 'required|integer|min:1',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = $request->user();
        $eventId = $request->event_id;
        $categoryId = $request->ticket_category_id;
        $quantity = $request->quantity;

        $category = TicketCategory::lockForUpdate()->find($categoryId);
        if (!$category || $category->event_id != $eventId) {
            return response()->json(['message' => 'Invalid ticket category.'], 400);
        }
        if ($category->quota - $category->sold < $quantity) {
            return response()->json(['message' => 'Not enough ticket quota.'], 409);
        }

        $transaction = null;
        DB::beginTransaction();
        try {
            // Update sold
            $category->sold += $quantity;
            $category->save();

            // Create transaction
            $transaction = Transaction::create([
                'user_id' => $user->id,
                'event_id' => $eventId,
                'total_amount' => $category->price * $quantity,
                'status' => 'pending',
            ]);

            // Create tickets & transaction details
            for ($i = 0; $i < $quantity; $i++) {
                $ticket = Ticket::create([
                    'ticket_category_id' => $categoryId,
                    'user_id' => $user->id,
                    'qr_code' => Str::uuid(),
                    'status' => 'booked',
                    'expired_at' => now()->addMinutes(15),
                ]);
                TransactionDetail::create([
                    'transaction_id' => $transaction->id,
                    'ticket_id' => $ticket->id,
                    'quantity' => 1,
                    'price' => $category->price,
                ]);
            }

            DB::commit();

            // Logging booking
            LogHelper::log($user->id, 'booking', 'Booking tiket event #' . $eventId . ' kategori #' . $categoryId . ' qty ' . $quantity);

            // Dispatch auto-cancel job (15 menit)
            AutoCancelUnpaidBooking::dispatch($transaction->id)->delay(now()->addMinutes(15));

            // Dispatch email job (dummy, hanya jika sudah paid, bisa juga dipanggil dari webhook)
            // SendTicketEmail::dispatch($transaction->id);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Booking failed', 'error' => $e->getMessage()], 500);
        }

        return response()->json(['message' => 'Booking successful', 'transaction_id' => $transaction->id], 201);
    }
}
