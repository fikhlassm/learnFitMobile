<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class StudyTechnique extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function quizResults(): HasMany
    {
        return $this->hasMany(QuizResult::class);
    }

    public function studySessions(): HasMany
    {
        return $this->hasMany(StudySession::class);
    }
}
