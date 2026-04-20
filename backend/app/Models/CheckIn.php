<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CheckIn extends Model
{
    use HasFactory;
    protected $fillable = [
        'ticket_id',
        'checked_in_at',
        'device_info',
    ];

    public function ticket()
    {
        return $this->belongsTo(Ticket::class);
    }
}
