<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Flashcard;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\Support\Facades\Auth;

class FlashcardController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware('can:modify,flashcard', except: ['store']),
        ];
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $validated = $request->validate([
            'study_session_id' => ['required', 'exists:study_sessions,id'],
        ]);

        $session = Auth::user()->studySessions()->findOrFail($validated['study_session_id']);

        $flashcards = $session->flashcards()->get();

        return response()->json($flashcards, 200);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'study_session_id' => ['required', 'exists:study_sessions,id'],
            'question' => ['required', 'min:3'],
            'answer' => ['required'],
        ]);

        $session = Auth::user()->studySessions()->findOrFail($validated['study_session_id']);

        $flashcard = $session->flashcards()->create([
            'question' => $validated['question'],
            'answer' => $validated['answer'],
        ]);

        return response()->json($flashcard, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Flashcard $flashcard)
    {
        return response()->json($flashcard, 200);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Flashcard $flashcard)
    {
        $validated = $request->validate([
            'question' => ['required', 'min:3'],
            'answer' => ['required'],
        ]);

        $flashcard->question = $validated['question'];
        $flashcard->answer = $validated['answer'];
        $flashcard->save();

        return response()->json($flashcard, 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Flashcard $flashcard)
    {
        $flashcard->delete();

        return response()->json([
            'message' => 'Successfully deleted flashcard',
        ], 200);
    }
}
