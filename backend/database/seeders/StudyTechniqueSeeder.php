<?php

namespace Database\Seeders;

use App\Models\StudyTechnique;
use Illuminate\Database\Seeder;

class StudyTechniqueSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        StudyTechnique::query()->create([
            'name' => 'Pomodoro Technique',
            'description' => 'A time management method using a timer to break work down into intervals.',
        ]);

        StudyTechnique::query()->create([
            'name' => 'Feynman Technique',
            'description' => 'A method of learning a concept by explaining it in plain, simple terms.',
        ]);

        StudyTechnique::query()->create([
            'name' => 'Active Recall',
            'description' => 'A principle of efficient learning by actively stimulating memory during review.',
        ]);

        StudyTechnique::query()->create([
            'name' => 'Blurting',
            'description' => 'Review a specific topic, section of your notes, or a textbook chapter for 10-15 minutes..',
        ]);
    }
}
