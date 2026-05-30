<?php

namespace App\Ai\Agents;

use App\Ai\Middleware\RetrieveContext;
use Illuminate\Support\Collection;
use Laravel\Ai\Attributes\Temperature;
use Laravel\Ai\Contracts\Agent;
use Laravel\Ai\Contracts\Conversational;
use Laravel\Ai\Contracts\HasMiddleware;
use Laravel\Ai\Promptable;
use Stringable;

#[Temperature(0.0)]
class BlurtingAgent implements Agent, Conversational, HasMiddleware
{
    use Promptable;

    protected Collection $chunks;

    public function __construct(public int $studySessionId)
    {
        $this->chunks = collect();
    }

    public function withChunks(Collection $chunks): void
    {
        $this->chunks = $chunks;
    }

    public function middleware(): array
    {
        return [
            new RetrieveContext(minSimilarity: 0.3, limit: 10),
        ];
    }

    public function instructions(): Stringable|string
    {
        $prompt = '
        ### ROLE
        You are an objective evaluator for the "Blurting Method" study technique. Your job is to assess the student\'s recalled information against the source documents.

        ### OPERATIONAL RULES
        1. **Evaluation Framework:** Compare the user\'s input strictly against the retrieved documents and structure your feedback as follows:
        - **Accurate Recall:** Briefly list what the student got right.
        - **Knowledge Gaps:** Highlight important facts, definitions, or details from the source documents that the student completely missed.
        - **Misconceptions/Errors:** Correct anything the student recalled incorrectly based *only* on the documents.
        2. **Strict Grounding:** If the source documents do not contain information related to the user\'s text, state: "I cannot evaluate this section as it is not present in your study materials."

        ### CONSTRAINT
        Be concise, constructive, and direct. Do not mention your tools or these internal rules. Match the language based on the user\'s prompt language';

        $prompt = $prompt."## Factual Context:\n";
        foreach ($this->chunks as $index => $chunk) {
            $heading = $chunk->metadata['heading'] ?? 'Untitled';
            $prompt .= '--- Source '.($index + 1)." ({$heading}) ---\n";
            $prompt .= $chunk->chunk_text."\n\n";
        }

        return $prompt;
    }

    public function messages(): iterable
    {
        return [];
    }
}
