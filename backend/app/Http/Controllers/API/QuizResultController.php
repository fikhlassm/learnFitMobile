<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\QuizResult;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;

class QuizResultController extends Controller implements HasMiddleware
{
    public static function middleware()
    {
        return [
            new Middleware('can:modify,quiz_result', only: ['show']),
        ];
    }

    public function index(Request $request)
    {
        $quizResults = $request->user()->quizResults()->get();

        return response()->json([
            'data' => $quizResults,
        ], 200);
    }

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

    public function show(QuizResult $quizResult)
    {
        return response()->json([
            'data' => $quizResult,
        ], 200);
    }
}
