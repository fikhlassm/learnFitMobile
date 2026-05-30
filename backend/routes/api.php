<?php

use App\Ai\Agents\BlurtingAgent;
use App\Http\Controllers\API\AttachmentController;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\FlashcardController;
use App\Http\Controllers\API\ForgotPasswordController;
use App\Http\Controllers\API\OtpController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\API\QuizResultController;
use App\Http\Controllers\API\SessionLogController;
use App\Http\Controllers\API\StudySessionController;
use App\Http\Controllers\API\UserDailyStatController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login'])->name('login');
Route::post('/otp/verify', [OtpController::class, 'validateOtp']);
Route::post('/otp/resend', [OtpController::class, 'resendOtp']);

Route::post('/forgot-password', [ForgotPasswordController::class, 'store'])->name('password.email');

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::apiResource('quiz-results', QuizResultController::class)->only(['index', 'store', 'show']);
    Route::apiResource('study-sessions', StudySessionController::class);
    Route::apiResource('flashcards', FlashcardController::class);
    Route::apiSingleton('profile', ProfileController::class)->destroyable();
    Route::apiResource('session-logs', SessionLogController::class)->only(['index', 'store', 'show', 'destroy']);
    Route::apiResource('user-daily-stats', UserDailyStatController::class)->only(['index', 'show']);
    Route::prefix('study-sessions/{study_session}')->group(function () {
        Route::apiResource('/attachments', AttachmentController::class)->only(['index', 'store', 'show', 'destroy']);
    });
});
