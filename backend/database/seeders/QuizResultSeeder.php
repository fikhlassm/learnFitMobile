<?php

namespace Database\Seeders;

use App\Models\QuizResult;
use App\Models\StudyTechnique;
use App\Models\User;
use Illuminate\Database\Seeder;

class QuizResultSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $imam = User::query()->where('email', 'imam@gmail.com')->first();
        $budi = User::query()->where('email', 'budi@gmail.com')->first();

        $pomodoro = StudyTechnique::query()->where('name', 'Pomodoro Technique')->first();
        $activeRecall = StudyTechnique::query()->where('name', 'Active Recall')->first();

        QuizResult::query()->create([
            'user_id' => $imam->id,
            'study_technique_id' => $activeRecall->id,
            'created_at' => now(),
        ]);

        QuizResult::query()->create([
            'user_id' => $budi->id,
            'study_technique_id' => $pomodoro->id,
            'created_at' => now(),
        ]);

    }
}
