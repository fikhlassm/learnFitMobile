<?php

namespace App\Policies;

use App\Models\Flashcard;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class FlashcardPolicy
{
    public function modify(User $user, Flashcard $flashcard): Response
    {
        return $$flashcard->studySession->user_id === $user->id
            ? Response::allow()
            : Response::deny();
    }
}
