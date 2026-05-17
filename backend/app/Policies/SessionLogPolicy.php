<?php

namespace App\Policies;

use App\Models\SessionLog;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class SessionLogPolicy
{
    public function modify(User $user, SessionLog $sessionLog): Response
    {
        return $sessionLog->studySession->user_id === $user->id
            ? Response::allow()
            : Response::deny();
    }
}
