<?php

namespace App\Http\Controllers;

use App\Models\QuizResult;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class QuizResultController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return response()->json(Auth::user()->quizResults()->get(), 200);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        QuizResult::query()->create([
            'user_id' => $request->user()->id,
            'study_technique_id' => $request->input('study_technique_id'),
        ]);

        return response()->json([
            'message' => 'Successfully created quiz result',
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(QuizResult $quizResult)
    {
        if ($quizResult->user_id !== auth()->id()) {
+           abort(403, 'Unauthorized');
+       }
        return response()->json($quizResult, 200);
    }
}
