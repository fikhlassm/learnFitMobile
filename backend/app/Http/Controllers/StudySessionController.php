<?php

namespace App\Http\Controllers;

use App\Models\StudySession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class StudySessionController extends Controller
{
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

        $studySession = StudySession::query()->create([
            'user_id' => $request->user()->id,
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
        if ($studySession->user_id !== Auth::id()) {
            abort(403, 'Unauthorized');
        }
        
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
