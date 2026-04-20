<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Transaction;
use Illuminate\Support\Facades\Auth;
use App\Models\Event;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Http;

class TransactionController extends Controller
{
    // GET /api/transactions
    public function index(Request $request)
    {
        $user = Auth::user();
        $transactions = Transaction::with(['event', 'details.ticket'])->where('user_id', $user->id)->get();
        return response()->json($transactions);
    }

    // GET /api/transactions/{id}
    public function show($id)
    {
        $transaction = Transaction::with(['event', 'details.ticket'])->find($id);
        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }
        return response()->json($transaction);
    }

    // Organizer: ringkasan penjualan per event
    public function organizerEventSales(Request $request, $event_id)
    {
        $user = Auth::user();
        $organizer = $user->organizer ?? null;
        if (!$organizer) {
            return response()->json(['message' => 'Organizer profile not found.'], 422);
        }

        $event = Event::findOrFail($event_id);
        if ($event->organizer_id !== $organizer->id && $user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $paidTx = Transaction::where('event_id', $event_id)->where('status', 'paid');
        $totalRevenue = (float) $paidTx->sum('total_amount');
        $totalTransactions = $paidTx->count();

        $ticketsSold = (int) DB::table('transaction_details')
            ->join('transactions', 'transactions.id', '=', 'transaction_details.transaction_id')
            ->where('transactions.event_id', $event_id)
            ->where('transactions.status', 'paid')
            ->sum('transaction_details.quantity');

        $perCategory = DB::table('tickets')
            ->join('transaction_details', 'transaction_details.ticket_id', '=', 'tickets.id')
            ->join('ticket_categories', 'ticket_categories.id', '=', 'tickets.ticket_category_id')
            ->join('transactions', 'transactions.id', '=', 'transaction_details.transaction_id')
            ->where('transactions.event_id', $event_id)
            ->where('transactions.status', 'paid')
            ->select('ticket_categories.id', 'ticket_categories.name', DB::raw('SUM(transaction_details.quantity) as sold'), DB::raw('SUM(transaction_details.quantity * transaction_details.price) as revenue'))
            ->groupBy('ticket_categories.id', 'ticket_categories.name')
            ->get();

        return response()->json([
            'event' => $event,
            'total_revenue' => $totalRevenue,
            'total_transactions' => $totalTransactions,
            'tickets_sold' => $ticketsSold,
            'by_category' => $perCategory,
        ]);
    }

    // CUSTOMER: upload payment proof (multipart form 'proof')
    public function uploadProof(Request $request, $id)
    {
        $user = Auth::user();
        $tx = Transaction::find($id);
        if (!$tx) return response()->json(['message' => 'Transaction not found'], 404);
        if ($tx->user_id !== $user->id) return response()->json(['message' => 'Unauthorized'], 403);

        $validator = Validator::make($request->all(), [
            'proof' => 'required|file|mimes:jpg,jpeg,png,pdf|max:5120',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $file = $request->file('proof');
        $path = $file->store('payments', 'public');
        $tx->proof_path = $path;
        $tx->status = 'pending';
        $tx->save();

        return response()->json(['message' => 'Proof uploaded', 'transaction' => $tx]);
    }

    // ORGANIZER: list transactions (pending) for an event
    public function organizerEventTransactions(Request $request, $event_id)
    {
        $user = Auth::user();
        $organizer = $user->organizer ?? null;
        if (!$organizer) {
            return response()->json(['message' => 'Organizer profile not found.'], 422);
        }

        $event = Event::findOrFail($event_id);
        if ($event->organizer_id !== $organizer->id && $user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $tx = Transaction::with(['user', 'details.ticket'])->where('event_id', $event_id)->where('status', 'pending')->whereNotNull('proof_path')->get();
        return response()->json(['data' => $tx]);
    }

    // ORGANIZER: approve or reject a transaction (body: approve = true|false)
    public function approve(Request $request, $id)
    {
        $user = Auth::user();
        $tx = Transaction::with(['event', 'details.ticket'])->find($id);
        if (!$tx) return response()->json(['message' => 'Transaction not found'], 404);

        $event = $tx->event;
        $organizer = $user->organizer ?? null;
        if (!$organizer && $user->role !== 'admin') {
            return response()->json(['message' => 'Organizer profile not found.'], 422);
        }
        if ($user->role !== 'admin' && $event->organizer_id !== $organizer->id) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $approve = $request->input('approve', true);
        if ($approve) {
            $tx->status = 'paid';
            $tx->paid_at = now();
            $tx->approved_at = now();
            $tx->approved_by = $user->id;
            $tx->save();

            // mark tickets as paid and generate QR image files
            foreach ($tx->details as $detail) {
                $ticket = $detail->ticket;
                if ($ticket) {
                    $ticket->status = 'paid';
                    $ticket->expired_at = null;
                    if (!$ticket->qr_code) $ticket->qr_code = (string) Str::uuid();
                    $ticket->save();

                    // Generate QR image via external QR API and save to storage/public/qrcodes/{ticket_id}.png
                    try {
                        $qrData = $ticket->qr_code;
                        $qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=500x500&data=' . urlencode($qrData);
                        $response = Http::get($qrUrl);
                        if ($response->ok()) {
                            Storage::disk('public')->put('qrcodes/' . $ticket->id . '.png', $response->body());
                        }
                    } catch (\Exception $e) {
                        // don't fail approval if QR generation fails; log later if needed
                    }
                }
            }

            return response()->json(['message' => 'Payment approved', 'transaction' => $tx->load('details.ticket')]);
        } else {
            $tx->status = 'cancelled';
            $tx->save();
            return response()->json(['message' => 'Payment rejected', 'transaction' => $tx]);
        }
    }
}
