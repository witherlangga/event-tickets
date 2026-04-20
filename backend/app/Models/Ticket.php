<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;

class Ticket extends Model
{
    use HasFactory, SoftDeletes;
    protected $appends = ['qr_image_url'];
    protected $fillable = [
        'ticket_category_id',
        'user_id',
        'qr_code',
        'status',
        'expired_at',
    ];

    public function category()
    {
        return $this->belongsTo(TicketCategory::class, 'ticket_category_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function checkIn()
    {
        return $this->hasOne(CheckIn::class);
    }

    public function getQrImageUrlAttribute()
    {
        $path = 'qrcodes/' . $this->id . '.png';
        if (Storage::disk('public')->exists($path)) {
            return Storage::url($path);
        }
        return null;
    }
}
