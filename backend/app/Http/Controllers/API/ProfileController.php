<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'data' => $user,
        ], 200);
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'min:3', 'max:225'],
            'grade' => ['nullable'],
        ]);

        $user = $request->user();
        $user->update([
            'name' => $validated['name'],
            'grade' => $validated['grade'],
        ]);

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
