<?php
namespace App\Helpers;

use App\Models\Log;
use Illuminate\Support\Facades\Request;

class LogHelper
{
    public static function log($userId, $action, $description = null)
    {
        Log::create([
            'user_id' => $userId,
            'action' => $action,
            'description' => $description,
            'ip_address' => Request::ip(),
        ]);
    }
}
