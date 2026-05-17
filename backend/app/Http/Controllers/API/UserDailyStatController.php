<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\UserDailyStat;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;

class UserDailyStatController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware('can:modify,user_daily_stat', only: ['show']),
        ];
    }

    public function index(Request $request)
    {
        $validated = $request->validate([
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date', 'after_or_equal:start_date'],
        ]);

        $dailyStats = $request->user()
            ->userDailyStats()
            ->when(isset($validated['start_date']), function ($query) use ($validated) {
                $query->whereDate('date', '>=', $validated['start_date']);
            })
            ->when(isset($validated['end_date']), function ($query) use ($validated) {
                $query->whereDate('date', '<=', $validated['end_date']);
            })
            ->orderBy('date')
            ->get();

        return response()->json([
            'data' => $dailyStats,
        ], 200);
    }

    public function show(Request $request, UserDailyStat $userDailyStat)
    {
        return response()->json([
            'data' => $userDailyStat,
        ], 200);
    }

}
