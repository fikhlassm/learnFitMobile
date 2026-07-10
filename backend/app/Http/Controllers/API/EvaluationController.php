<?php

namespace App\Http\Controllers\API;

use App\Ai\Agents\BlurtingAgent;
use App\Ai\Agents\FeynmanAgent;
use App\Http\Controllers\Controller;
use App\Models\StudySession;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;

class EvaluationController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware('can:modify,study_session', only: ['evaluate']),
        ];
    }

    public function evaluate(Request $request, StudySession $studySession)
    {
        $request->validate([
            'text' => ['required', 'min:10'],
        ]);

        $prompt = $request->text;

        $studySessionId = $studySession->id;
        $technique = $studySession->studyTechnique->name;

        if (! in_array($technique, ['feynman', 'blurting'], true)) {
            return response()->json([
                'message' => 'AI evaluation is not available for this study technique.',
            ], 422);
        }

        try {
            if ($technique === 'feynman') {
                $response = FeynmanAgent::make($studySessionId)->prompt($prompt);
            } else {
                $response = BlurtingAgent::make($studySessionId)->prompt($prompt);
            }

            return response()->json([
                'feedback' => $response->text,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'The AI evaluation service is currently unavailable. Please try again later.',
            ], 503);
        }

    }
}
