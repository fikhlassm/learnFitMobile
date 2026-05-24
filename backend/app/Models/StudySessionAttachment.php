<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudySessionAttachment extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function studySession(): BelongsTo
    {
        return $this->belongsTo(StudySession::class);
    }
}
