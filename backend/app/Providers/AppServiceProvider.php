<?php

namespace App\Providers;

use Akira\Rag\Models\RagEmbedding;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RagEmbedding::creating(function ($model) {
            $embedding = $model->embedding;

            if (
                empty($embedding) ||
                (is_string($embedding) && strlen($embedding) < 100) ||
                (is_array($embedding) && count($embedding) < 1536)
            ) {
                $model->embedding = array_fill(0, 1536, 0);
            }
        });
    }
}
