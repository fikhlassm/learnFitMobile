<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::factory()->create([
            'name' => 'imam',
            'email' => 'imam@gmail.com',
            'password' => 'imam1234',
            'grade' => '12',
        ]);

        User::factory()->create([
            'name' => 'budi',
            'email' => 'budi@gmail.com',
            'password' => 'budi1234',
            'grade' => '10',
        ]);

    }
}
