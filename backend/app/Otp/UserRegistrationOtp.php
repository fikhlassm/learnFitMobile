<?php

namespace App\Otp;

use App\Models\User;
use Illuminate\Auth\Events\Registered;
use SadiqSalau\LaravelOtp\Contracts\OtpInterface as Otp;

class UserRegistrationOtp implements Otp
{
    /**
     * Constructs Otp class
     */
    public function __construct(
        protected string $name,
        protected string $email,
        protected string $password
    ) {}

    /**
     * Processes the Otp
     *
     * @return mixed
     */
    public function process()
    {
        $user = User::unguarded(function () {
            return User::query()->create([
                'name' => $this->name,
                'email' => $this->email,
                'password' => $this->password,
                'email_verified_at' => now(),
            ]);
        });

        event(new Registered($user));

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Succesfully created user',
            'access_token' => $token,
            'token_type' => 'bearer',
        ], 201);
    }
}
