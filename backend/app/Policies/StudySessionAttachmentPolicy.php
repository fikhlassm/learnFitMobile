<?php

namespace App\Policies;

use App\Models\StudySessionAttachment;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class StudySessionAttachmentPolicy
{
    public function modify(User $user, StudySessionAttachment $attachment): Response
    {
        return $attachment->studySession->user_id === $user->id
            ? Response::allow()
            : Response::denyAsNotFound();
    }
}
