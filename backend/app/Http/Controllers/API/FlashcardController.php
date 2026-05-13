<?php

namespace App\Http\Controllers;

use App\Models\Flashcard;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FlashcardController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $flashcards = Auth::user()->;

        
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(Flashcard $flashcard)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Flashcard $flashcard)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Flashcard $flashcard)
    {
        //
    }
}
