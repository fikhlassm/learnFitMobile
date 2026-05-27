<?php

namespace App\Services;

use App\Models\Attachment;
use App\Models\DocumentChunk;
use Illuminate\Support\Collection;
use Laravel\Ai\Embeddings;

class DocumentEmbedder
{
    public function process(Attachment $attachment, Collection $chunks): void
    {
        if ($chunks->isEmpty()) {
            return;
        }

        $texts = $chunks->pluck('text')->map(function ($text) {
            $cleanText = iconv('UTF-8', 'UTF-8//IGNORE', $text);
            $cleanText = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/', '', $cleanText);

            return $cleanText;
        })->toArray();

        $response = Embeddings::for($texts)->generate();

        foreach ($chunks as $index => $chunk) {
            $cleanHeading = $chunk['heading'] ? iconv('UTF-8', 'UTF-8//IGNORE', $chunk['heading']) : null;
            $cleanHeading = $cleanHeading ? preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/', '', $cleanHeading) : null;

            DocumentChunk::create([
                'source' => $attachment->file_name,
                'chunk_text' => $texts[$index],
                'metadata' => [
                    'heading' => $cleanHeading,
                    'hash' => hash('sha256', $texts[$index]),
                    'attachment_id' => $attachment->id,
                ],
                'study_session_id' => $attachment->study_session_id,
                'embedding' => $response->embeddings[$index],
            ]);
        }

    }
}
