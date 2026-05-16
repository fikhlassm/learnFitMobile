<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Otp\UserRegistrationOtp;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Notification;
use SadiqSalau\LaravelOtp\Facades\Otp;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'min:3', 'max:225'],
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', 'min:8', 'confirmed'],
        ]);

        $otp = Otp::identifier($validated['email'])->send(
            new UserRegistrationOtp(
                name: $validated['name'],
                email: $validated['email'],
                password: $validated['password']
            ),
            Notification::route('mail', $request->email)
        );

        if ($otp['status'] !== Otp::OTP_SENT) {
            return response()->json([
                'status' => 'error',
                'message' => __($otp['status']),
            ], 400);
        }

        return response()->json([
            'status' => 'success',
            'message' => __($otp['status']),
        ], 200);
    }

    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        // success login
        if (Auth::attempt([
            'email' => $validated['email'],
            'password' => $validated['password'],
        ])) {

            $token = Auth::user()->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'Succesfully logged in',
                'access_token' => $token,
                'token_type' => 'Bearer',
            ], 200);
        }

        // invalid user
        return response()->json([
            'message' => 'Invalid credentials',
        ], 401);
    }

    public function logout(Request $request)
    {
        $request->user()->tokens()->delete();

        return response()->json([
            'message' => 'Succesfully logged out',
        ], 200);
    }
}
