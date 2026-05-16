<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\StudySession;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;

class StudySessionController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware('can:modify,study_session', only: ['show', 'update', 'destroy']),
        ];
    }

    public function index(Request $request)
    {
        $studySessions = $request->user()->studySessions()->get();

        return response()->json([
            'data' => $studySessions,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'topic' => ['required', 'min:3', 'max:50'],
        ]);

        $studySession = $request->user()->studySessions()->create([
            'study_technique_id' => $request->input('study_technique_id'),
            'topic' => $validated['topic'],
        ]);

        return response()->json([
            'data' => $studySession,
        ], 201);
    }

    public function show(StudySession $studySession)
    {
        return response()->json([
            'data' => $studySession,
        ], 200);
    }

    public function update(Request $request, StudySession $studySession)
    {
        $studySession->content = $request->input('content');
        $studySession->save();

        return response()->json([
            'data' => $studySession,
        ], 200);
    }

    public function destroy(StudySession $studySession)
    {
        $studySession->delete();

        return response()->json([
            'message' => 'Successfully deleted study session',
        ], 200);
    }
}
