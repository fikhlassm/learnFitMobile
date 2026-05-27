<?php

namespace App\Jobs;

use App\Models\Attachment;
use App\Models\DocumentChunk;
use App\Services\DocumentChunker;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Laravel\Ai\Embeddings;

class ProcessEmbeddings implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public Attachment $attachment,
        public string $fileContent
    ) {}

    public function handle(DocumentChunker $chunker): void
    {
        // chunking
        $chunks = $chunker->chunk(
            $this->attachment->file_name,
            $this->fileContent
        );

        if ($chunks->isEmpty()) {
            return;
        }

        // embedding
        $texts = $chunks->pluck('text')->toArray();
        $response = Embeddings::for($texts)->generate();

        // store
        foreach ($chunks as $index => $chunk) {
            DocumentChunk::query()->create([
                'source' => $this->attachment->file_name,
                'chunk_text' => $chunk['text'],
                'metadata' => [
                    'heading' => $chunk['heading'],
                    'hash' => hash('sha256', $chunk['text']),
                    'attachment_id' => $this->attachment->id,
                    'study_session_id' => $this->attachment->study_session_id,
                ],
                'embedding' => $response->embeddings[$index],
            ]);
        }
    }
}
