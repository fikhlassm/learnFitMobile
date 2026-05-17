<?php

namespace App\Policies;

use App\Models\User;
use App\Models\UserDailyStat;
use Illuminate\Auth\Access\Response;

class UserDailyStatPolicy
{
    public function modify(User $user, UserDailyStat $userDailyStat): Response
    {
        return $userDailyStat->user_id === $user->id
            ? Response::allow()
            : Response::deny();
    }    
}
