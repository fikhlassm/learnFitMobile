<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;

class SupportController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'message' => ['required', 'string', 'min:5', 'max:5000'],
        ]);

        $user = $request->user();

        Mail::raw($validated['message'], function ($message) use ($user) {
            $message
                ->to(config('mail.support_address'))
                ->replyTo($user->email, $user->name)
                ->subject('LearnFit Support Message from ' . $user->name);
        });

        return response()->json([
            'message' => 'Support message sent successfully.',
        ], 200);
    }
}
