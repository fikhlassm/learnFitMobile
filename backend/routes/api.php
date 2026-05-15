<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\FlashcardController;
use App\Http\Controllers\API\OtpController;
use App\Http\Controllers\API\QuizResultController;
use App\Http\Controllers\API\StudySessionController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/otp/verify', [OtpController::class, 'validateOtp']);
Route::post('/otp/resend', [OtpController::class, 'resendOtp']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::apiResource('quiz-results', QuizResultController::class)->only(['index', 'store', 'show']);
    Route::apiResource('study-sessions', StudySessionController::class);
    Route::apiResource('flashcards', FlashcardController::class);
});
