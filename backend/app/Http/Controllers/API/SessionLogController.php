<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\SessionLog;
use App\Models\UserDailyStat;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\Support\Facades\Date;
use Illuminate\Support\Facades\DB;
use Throwable;

class SessionLogController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware('can:modify,session_log', only: ['show', 'destroy']),
        ];
    }

    public function index(Request $request)
    {
        $sessionLogs = SessionLog::query()
            ->whereHas('studySession', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->with('studySession')
            ->latest()
            ->get();

        return response()->json([
            'data' => $sessionLogs,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'study_session_id' => ['required', 'exists:study_sessions,id'],
            'duration_seconds' => ['required', 'integer', 'min:1'],
        ]);

        $user = $request->user();

        $studySession = $user
            ->studySessions()
            ->findOrFail($validated['study_session_id']);

        DB::beginTransaction();

        try {
            $sessionLog = $studySession->sessionLog()->create([
                'duration_seconds' => $validated['duration_seconds'],
            ]);

            // user_daily_stat
            $dailyStat = UserDailyStat::query()->firstOrCreate(
                [
                    'user_id' => $studySession->user_id,
                    'date' => now()->toDateString(),
                ],
                [
                    'total_seconds' => 0,
                ],
            );

            $dailyStat->increment('total_seconds', $validated['duration_seconds']);

            // user streak
            $lastStudyDate = $user->last_study_date;

            if (! $lastStudyDate || $lastStudyDate->isBefore(Date::now()->startOfDay()->subDay())) {
                $user->current_streak = 1;
            } elseif ($lastStudyDate->isYesterday()) {
                $user->current_streak += 1;
            }

            $user->last_study_date = Date::now();
            $user->save();

            DB::commit();

            return response()->json([
                'message' => 'Successfully created session log',
                'data' => $sessionLog->load('studySession'),
            ], 201);

        } catch (Throwable $throwable) {
            DB::rollBack();

            return response()->json([
                'message' => 'Failed to create session log',
            ], 500);
        }
    }

    public function show(Request $request, SessionLog $sessionLog)
    {
        return response()->json([
            'data' => $sessionLog->load('studySession'),
        ], 200);
    }

    public function destroy(Request $request, SessionLog $sessionLog)
    {
        DB::beginTransaction();

        try {
            $studySession = $sessionLog->studySession;
            $durationSeconds = $sessionLog->duration_seconds;
            $logDate = $sessionLog->created_at->toDateString();

            $sessionLog->delete();

            $dailyStat = UserDailyStat::query()
                ->where('user_id', $studySession->user_id)
                ->where('date', $logDate)
                ->first();

            if ($dailyStat !== null) {
                $dailyStat->total_seconds = max(0, $dailyStat->total_seconds - $durationSeconds);
                $dailyStat->save();
            }

            DB::commit();

            return response()->json([
                'message' => 'Successfully deleted session log',
            ], 200);
        } catch (Throwable $throwable) {
            DB::rollBack();

            report($throwable);

            return response()->json([
                'message' => 'Failed to delete session log',
            ], 500);
        }
    }
}
