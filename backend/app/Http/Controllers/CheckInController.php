<?php
namespace App\Http\Controllers;

use App\Models\Ticket;
use App\Models\CheckIn;
use Illuminate\Http\Request;
use App\Helpers\LogHelper;

class CheckInController extends Controller
{
    // Endpoint validasi QR code dan check-in
    public function scan(Request $request)
    {
        $request->validate([
            'qr_code' => 'required|string',
        ]);
        $ticket = Ticket::where('qr_code', $request->qr_code)->first();
        if (!$ticket) {
            return response()->json(['message' => 'Tiket tidak ditemukan'], 404);
        }
        if ($ticket->status !== 'paid') {
            return response()->json(['message' => 'Tiket belum dibayar atau sudah digunakan'], 422);
        }
        // Cek apakah sudah check-in
        if ($ticket->checkIn) {
            return response()->json(['message' => 'Tiket sudah check-in'], 409);
        }
        // Proses check-in
        $ticket->status = 'checked_in';
        $ticket->save();
        $checkIn = CheckIn::create([
            'ticket_id' => $ticket->id,
            'checked_in_at' => now(),
            'device_info' => $request->header('User-Agent'),
        ]);
        LogHelper::log($ticket->user_id, 'checkin', 'Check-in tiket #' . $ticket->id);
        return response()->json(['message' => 'Check-in berhasil', 'check_in' => $checkIn]);
    }
}
