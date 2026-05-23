<?php

namespace Database\Seeders;

use App\Models\Flashcard;
use App\Models\SessionLog;
use App\Models\StudySession;
use App\Models\StudyTechnique;
use App\Models\User;
use App\Models\UserDailyStat;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Date;

class StudySessionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $imam = User::query()->where('email', 'imam@gmail.com')->first();
        $budi = User::query()->where('email', 'budi@gmail.com')->first();

        $pomodoro = StudyTechnique::query()->where('name', 'pomodoro')->first();
        $feynman = StudyTechnique::query()->where('name', 'feynman')->first();
        $activeRecall = StudyTechnique::query()->where('name', 'active recall')->first();
        $blurting = StudyTechnique::query()->where('name', 'blurting')->first();

        // imam session 1: active recall
        $imamSession1 = StudySession::query()->create([
            'user_id' => $imam->id,
            'study_technique_id' => $activeRecall->id,
            'topic' => 'Biology: Sel',
            'content' => null,
            'created_at' => Date::now()->subDays(1),
        ]);

        // flashcard imam session 1
        Flashcard::query()->create([
            'study_session_id' => $imamSession1->id,
            'question' => 'What is the powerhouse of the cell?',
            'answer' => 'Mitochondria',
        ]);
        Flashcard::query()->create([
            'study_session_id' => $imamSession1->id,
            'question' => 'What is the name of shi that makes plants turn green?',
            'answer' => 'Chlorophyll',
        ]);

        // logging imam session 1
        $imamLog1 = SessionLog::query()->create([
            'study_session_id' => $imamSession1->id,
            'duration_seconds' => 2700,
            'created_at' => $imamSession1->created_at,
        ]);
        UserDailyStat::query()->updateOrCreate([
            'user_id' => $imam->id,
            'date' => $imamSession1->created_at->toDateString(),
            'total_seconds' => $imamLog1->duration_seconds,
        ]);

        // imam session 2: pomodoro
        $imamSession2 = StudySession::query()->create([
            'user_id' => $imam->id,
            'study_technique_id' => $pomodoro->id,
            'topic' => 'Golang',
            'content' => 'Array and slice has similar trait',
            'created_at' => Date::now()->subDays(2),
        ]);

        // logging imam session 2
        $imamLog2 = SessionLog::query()->create([
            'study_session_id' => $imamSession2->id,
            'duration_seconds' => 3000,
            'created_at' => $imamSession2->created_at,
        ]);
        UserDailyStat::query()->updateOrCreate([
            'user_id' => $imam->id,
            'date' => $imamSession2->created_at->toDateString(),
            'total_seconds' => $imamLog2->duration_seconds,
        ]);

        // imam session 3: feynman
        $imamSession3 = StudySession::query()->create([
            'user_id' => $imam->id,
            'study_technique_id' => $feynman->id,
            'topic' => 'Black hole',
            'content' => 'Black hole is a hole that is black',
            'created_at' => Date::now()->subDays(3),
        ]);

        // logging imam session 3
        $imamLog3 = SessionLog::query()->create([
            'study_session_id' => $imamSession3->id,
            'duration_seconds' => 5000,
            'created_at' => $imamSession3->created_at,
        ]);
        UserDailyStat::query()->updateOrCreate([
            'user_id' => $imam->id,
            'date' => $imamSession3->created_at->toDateString(),
            'total_seconds' => $imamLog3->duration_seconds,
        ]);

        // budi session 1: blurting
        $budiSession1 = StudySession::query()->create([
            'user_id' => $budi->id,
            'study_technique_id' => $blurting->id,
            'topic' => 'Math',
            'content' => '1 + 1 equals 2',
            'created_at' => Date::now()->subDays(1),
        ]);

        // logging budi session 1
        $budiLog1 = SessionLog::query()->create([
            'study_session_id' => $budiSession1->id,
            'duration_seconds' => 3456,
            'created_at' => $budiSession1->created_at,
        ]);
        UserDailyStat::query()->updateOrCreate([
            'user_id' => $budi->id,
            'date' => $budiSession1->created_at->toDateString(),
            'total_seconds' => $budiLog1->duration_seconds,
        ]);

        // budi session 2: pomodoro
        $budiSession2 = StudySession::query()->create([
            'user_id' => $budi->id,
            'study_technique_id' => $pomodoro->id,
            'topic' => 'Python',
            'content' => 'Idk',
            'created_at' => Date::now()->subDays(3),
        ]);

        // logging budi session 2
        $budiLog2 = SessionLog::query()->create([
            'study_session_id' => $budiSession2->id,
            'duration_seconds' => 6000,
            'created_at' => $budiSession2->created_at,
        ]);
        UserDailyStat::query()->updateOrCreate([
            'user_id' => $budi->id,
            'date' => $budiSession2->created_at->toDateString(),
            'total_seconds' => $budiLog2->duration_seconds,
        ]);

    }
}
