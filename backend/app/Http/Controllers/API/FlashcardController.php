<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Flashcard;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;

class FlashcardController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware('can:modify,flashcard', except: ['store', 'index']),
        ];
    }

    public function index(Request $request)
    {
        $validated = $request->validate([
            'study_session_id' => ['required', 'exists:study_sessions,id'],
        ]);

        $session = $request->user()->studySessions()->findOrFail($validated['study_session_id']);

        $flashcards = $session->flashcards()->get();

        return response()->json([
            'data' => $flashcards,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'study_session_id' => ['required', 'exists:study_sessions,id'],
            'question' => ['required', 'min:3'],
            'answer' => ['required'],
        ]);

        $session = $request->user()->studySessions()->findOrFail($validated['study_session_id']);

        $flashcard = $session->flashcards()->create([
            'question' => $validated['question'],
            'answer' => $validated['answer'],
        ]);

        return response()->json([
            'data' => $flashcard,
        ], 201);
    }

    public function show(Flashcard $flashcard)
    {
        return response()->json([
            'data' => $flashcard,
        ], 200);
    }

    public function update(Request $request, Flashcard $flashcard)
    {
        $validated = $request->validate([
            'question' => ['required', 'min:3'],
            'answer' => ['required'],
        ]);

        $flashcard->question = $validated['question'];
        $flashcard->answer = $validated['answer'];
        $flashcard->save();

        return response()->json([
            'data' => $flashcard,
        ], 200);
    }

    public function destroy(Flashcard $flashcard)
    {
        $flashcard->delete();

        return response()->json([
            'message' => 'Successfully deleted flashcard',
        ], 200);
    }
}
