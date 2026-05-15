<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
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

        return response()->json([
            'status' => 'success',
            'message' => 'Account verified and created successfully.',
            'data' => $otp['result'],
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
