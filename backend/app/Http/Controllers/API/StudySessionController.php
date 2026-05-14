<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\StudySession;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\Support\Facades\Auth;

class StudySessionController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware('can:modify,study_sessions', only: ['show','update', 'destroy']),
        ];
    }
    
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $studySessions = Auth::user()->studySessions()->get();

        return response()->json($studySessions, 200);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'topic' => ['required', 'min:3', 'max:50'],
        ]);

        $studySession = Auth::user()->studySessions()->create([
            'study_technique_id' => $request->input('study_technique_id'),
            'topic' => $validated['topic'],
        ]);

        return response()->json($studySession, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(StudySession $studySession)
    {   
        return response()->json($studySession, 200);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, StudySession $studySession)
    {
        $studySession->content = $request->input('content');
        $studySession->save();

        return response()->json($studySession, 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(StudySession $studySession)
    {
        $studySession->delete();

        return response()->json([
            'message' => 'Successfully deleted study session',
        ], 200);
    }
}
