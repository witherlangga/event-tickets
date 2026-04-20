<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Models\User;

class DataMiningController extends Controller
{
    // Endpoint segmentasi user (stub Hybrid K-Means + C4.5)
    public function segmentUsers(Request $request)
    {
        // Ambil data user dan histori transaksi (dummy, bisa dikembangkan)
        $users = User::with(['transactions'])->get();

        // --- Stub Hybrid Data Mining ---
        // 1. K-Means clustering (dummy)
        $clusters = [
            'A' => [], // High spender
            'B' => [], // Medium spender
            'C' => [], // Low spender
        ];
        foreach ($users as $user) {
            $total = $user->transactions->sum('total_amount');
            if ($total > 1000000) {
                $clusters['A'][] = $user;
            } elseif ($total > 300000) {
                $clusters['B'][] = $user;
            } else {
                $clusters['C'][] = $user;
            }
        }
        // 2. C4.5 Decision Tree (dummy, return rekomendasi event)
        $recommendations = [];
        foreach ($clusters as $label => $usersInCluster) {
            foreach ($usersInCluster as $user) {
                $recommendations[] = [
                    'user_id' => $user->id,
                    'segment' => $label,
                    'recommendation' => 'Event rekomendasi untuk segmen ' . $label,
                ];
            }
        }
        Log::info('Hybrid Data Mining executed');
        return response()->json($recommendations);
    }
}
