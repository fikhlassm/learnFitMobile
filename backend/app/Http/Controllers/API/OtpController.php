<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use SadiqSalau\LaravelOtp\Facades\Otp;

class OtpController extends Controller
{
    public function validateOtp(Request $request)
    {
        $request->validate([
            'email' => ['required', 'string', 'email', 'max:255'],
            'code' => ['required', 'string'],
        ]);

        $otp = Otp::identifier($request->email)->attempt($request->code);

        if ($otp['status'] !== Otp::OTP_PROCESSED) {
            return response()->json([
                'status' => 'error',
                'message' => __($otp['status']),
            ], 403);
        }

        $user = User::query()->where('email', $request->email)->first();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Account verified and created successfully.',
            'access_token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    public function resendOtp(Request $request)
    {
        $request->validate([
            'email' => ['required', 'string', 'email', 'max:255'],
        ]);

        $otp = Otp::identifier($request->email)->update();

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
}
