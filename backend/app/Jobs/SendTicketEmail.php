<?php
namespace App\Jobs;

use App\Models\Transaction;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class SendTicketEmail implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $transactionId;

    /**
     * Create a new job instance.
     */
    public function __construct($transactionId)
    {
        $this->transactionId = $transactionId;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $transaction = Transaction::with(['user', 'details.ticket'])->find($this->transactionId);
        if ($transaction && $transaction->status === 'paid') {
            // Kirim email tiket ke user (dummy, implementasi PDF/email bisa dikembangkan)
            Mail::raw('Tiket Anda berhasil dibeli. Detail: ' . $transaction->id, function ($message) use ($transaction) {
                $message->to($transaction->user->email)
                        ->subject('E-Ticket for Event #' . $transaction->event_id);
            });
        }
    }
}
