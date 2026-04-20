<?php
namespace App\Jobs;

use App\Models\Ticket;
use App\Models\Transaction;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class AutoCancelUnpaidBooking implements ShouldQueue
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
        $transaction = Transaction::find($this->transactionId);
        if ($transaction && $transaction->status === 'pending') {
            // Batalkan transaksi
            $transaction->status = 'cancelled';
            $transaction->save();
            // Batalkan semua tiket terkait
            foreach ($transaction->details as $detail) {
                $ticket = $detail->ticket;
                if ($ticket && $ticket->status === 'booked') {
                    $ticket->status = 'cancelled';
                    $ticket->save();
                }
            }
        }
    }
}
