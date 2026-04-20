<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Event extends Model
{
    use HasFactory, SoftDeletes;
    protected $fillable = [
        'organizer_id',
        'title',
        'description',
        'location',
        'latitude',
        'longitude',
        'start_time',
        'end_time',
        'banner',
        'status',
    ];

    protected $appends = ['banner_url'];

    public function organizer()
    {
        return $this->belongsTo(Organizer::class);
    }

    public function ticketCategories()
    {
        return $this->hasMany(TicketCategory::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function getBannerUrlAttribute()
    {
        if (!$this->banner) {
            return null;
        }
        return url('storage/' . $this->banner);
    }
}
