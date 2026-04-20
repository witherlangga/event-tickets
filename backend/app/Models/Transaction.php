<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'event_id',
        'total_amount',
        'status',
        'payment_method',
        'payment_gateway',
        'payment_reference',
        'paid_at',
        'proof_path',
        'approved_at',
        'approved_by',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function details()
    {
        return $this->hasMany(TransactionDetail::class);
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function tickets()
    {
        return $this->hasManyThrough(\App\Models\Ticket::class, TransactionDetail::class, 'transaction_id', 'id', 'id', 'ticket_id');
    }
}
