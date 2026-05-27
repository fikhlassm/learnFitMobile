<?php

namespace App\Services;

use Droath\TextChunker\Facades\TextChunker;
use Illuminate\Support\Collection;

class DocumentChunker
{
    public function chunk(string $filename, string $content): Collection
    {
        $chunks = TextChunker::strategy('token')
            ->size(500)
            ->overlap(10)
            ->chunk($content);

        return collect($chunks)
            ->map(fn ($chunk) => [
                'text' => trim($chunk->text),
                'heading' => "{$filename} - Chunk {$chunk->index}",
            ])
            ->filter(fn ($chunk) => $chunk['text'] !== '')
            ->values();
    }
}
