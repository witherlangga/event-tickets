<?php
namespace App\Http\Controllers;

use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Helpers\LogHelper;

class PaymentWebhookController extends Controller
{
    // Webhook endpoint untuk Midtrans
    public function midtrans(Request $request)
    {
        $payload = $request->all();
        Log::info('Midtrans Webhook', $payload);
        $orderId = $payload['order_id'] ?? null;
        $transactionStatus = $payload['transaction_status'] ?? null;
        $fraudStatus = $payload['fraud_status'] ?? null;

        if (!$orderId) {
            return response()->json(['message' => 'Invalid payload'], 400);
        }

        $transaction = Transaction::find($orderId);
        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }

        // Update status transaksi sesuai status dari Midtrans
        if ($transactionStatus === 'settlement' && $fraudStatus === 'accept') {
            $transaction->status = 'paid';
            $transaction->paid_at = now();
            LogHelper::log($transaction->user_id, 'payment', 'Pembayaran sukses via Midtrans untuk transaksi #' . $transaction->id);
        } elseif ($transactionStatus === 'expire') {
            $transaction->status = 'expired';
            LogHelper::log($transaction->user_id, 'payment', 'Transaksi expired via Midtrans untuk transaksi #' . $transaction->id);
        } elseif ($transactionStatus === 'cancel') {
            $transaction->status = 'cancelled';
            LogHelper::log($transaction->user_id, 'payment', 'Transaksi dibatalkan via Midtrans untuk transaksi #' . $transaction->id);
        }
        $transaction->save();

        return response()->json(['message' => 'OK']);
    }

    // Webhook endpoint untuk Xendit
    public function xendit(Request $request)
    {
        $payload = $request->all();
        Log::info('Xendit Webhook', $payload);
        $externalId = $payload['external_id'] ?? null;
        $status = $payload['status'] ?? null;

        if (!$externalId) {
            return response()->json(['message' => 'Invalid payload'], 400);
        }

        $transaction = Transaction::find($externalId);
        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }

        if ($status === 'PAID') {
            $transaction->status = 'paid';
            $transaction->paid_at = now();
            LogHelper::log($transaction->user_id, 'payment', 'Pembayaran sukses via Xendit untuk transaksi #' . $transaction->id);
        } elseif ($status === 'EXPIRED') {
            $transaction->status = 'expired';
            LogHelper::log($transaction->user_id, 'payment', 'Transaksi expired via Xendit untuk transaksi #' . $transaction->id);
        } elseif ($status === 'CANCELLED') {
            $transaction->status = 'cancelled';
            LogHelper::log($transaction->user_id, 'payment', 'Transaksi dibatalkan via Xendit untuk transaksi #' . $transaction->id);
        }
        $transaction->save();

        return response()->json(['message' => 'OK']);
    }
}
