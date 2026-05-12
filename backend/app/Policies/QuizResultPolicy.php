<?php

namespace App\Policies;

use App\Models\QuizResult;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class QuizResultPolicy
{
    public function modify(User $user, QuizResult $quizResult): Response
    {
        return $quizResult->user_id === $user->id 
            ? Response::allow() 
            : Response::deny(); 
    }
}
