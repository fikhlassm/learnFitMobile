<?php

namespace App\Policies;

use App\Models\Attachment;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class AttachmentPolicy
{
    public function modify(User $user, Attachment $attachment): Response
    {
        return $attachment->studySession->user_id === $user->id
            ? Response::allow()
            : Response::denyAsNotFound();
    }
}
