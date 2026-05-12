<?php

namespace App\Policies;

use App\Models\StudySession;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class StudySessionPolicy
{
    public function modify(User $user, StudySession $studySession): Response
    {
        return $studySession->user_id === $user->id 
            ? Response::allow() 
            : Response::deny(); 
    }
}
