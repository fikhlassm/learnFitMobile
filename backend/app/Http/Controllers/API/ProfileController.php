<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'data' => $user,
        ], 200);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['required', 'min:3', 'max:225'],
            'email' => [
                'sometimes',
                'email',
                'max:255',
                Rule::unique('users', 'email')->ignore($user->id),
            ],
            'grade' => ['sometimes', 'nullable', 'string', 'max:255'],
        ]);

        // Hanya update field yang benar-benar dikirim client.
        $user->fill(array_intersect_key(
            $validated,
            array_flip(['name', 'email', 'grade']),
        ));
        $user->save();

        return response()->json([
            'message' => 'Profile updated!',
            'data' => $user,
        ], 200);
    }

    public function destroy(Request $request)
    {
        $request->user()->tokens()->delete();
        $request->user()->delete();

        return response()->json([
            'message' => 'Account succesfully deleted!',
        ], 200);
    }
}
