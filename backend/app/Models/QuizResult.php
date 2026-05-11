<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QuizResult extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function studyTechnique(): BelongsTo
    {
        return $this->belongsTo(StudyTechnique::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
