<?php

namespace App\Http\Controllers\API;

use App\Ai\Agents\BlurtingAgent;
use App\Ai\Agents\FeynmanAgent;
use App\Http\Controllers\Controller;
use App\Models\StudySession;
use Illuminate\Http\Request;

class EvaluationController extends Controller
{
    public function evaluate(Request $request, StudySession $studySession)
    {
        $request-> validate([
            'text' => ['required', 'min:10']
        ]);

        $prompt = $request->text;

        $studySessionId = $studySession->id;
        $technique = $studySession->studyTechnique->name;

        try {
            if($technique === 'feynman') {
                $response = FeynmanAgent::make($studySessionId)->prompt($prompt);
            }

            if ($technique === 'blurting') {
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
