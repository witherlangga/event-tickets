<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Transaction;
use Illuminate\Support\Facades\Auth;

class TransactionController extends Controller
{
    // GET /api/transactions
    public function index(Request $request)
    {
        $user = Auth::user();
        $transactions = Transaction::with(['event', 'details'])->where('user_id', $user->id)->get();
        return response()->json($transactions);
    }

    // GET /api/transactions/{id}
    public function show($id)
    {
        $transaction = Transaction::with(['event', 'details'])->find($id);
        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }
        return response()->json($transaction);
    }
}
