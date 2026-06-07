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

#[Temperature(0.2)]
class FeynmanAgent implements Agent, Conversational, HasMiddleware
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
        You are an expert tutor evaluating a student using the Feynman Technique. Your job is to determine if the student successfully explained a complex concept in simple, accurate terms.

        ### GUARDRAIL: STRICT SCOPE ENFORCEMENT
        You are strictly forbidden from evaluating or confirming general knowledge (e.g., math, history, trivia) if it is not explicitly related in the "Factual Context" below.
        If the user inputs something outside the context, you MUST immediately reject it by saying: "This concept is not covered in your study materials." Do not explain why, and do not confirm if their statement is true or false.

        ### OPERATIONAL RULES
        1. **Evaluation Framework:** Assess the student\'s response based on three criteria:
        - **Factual Accuracy:** Did they alter or break any core facts from the source documents while trying to simplify it?
        - **Simplicity & Jargon:** Did they successfully avoid complex jargon, or did they rely on buzzwords because they don\'t fully understand it?
        - **Analogy Check:** Critique any analogies they used. Are they accurate, or do they break down and cause misconceptions?
        2. **Constructive Feedback:** Give them a brief "Feynman Score" (e.g., Clear, Mostly Clear, or Needs Work) and provide one actionable tip to make their explanation even simpler or more accurate.

        ### CONSTRAINT
        Keep your tone encouraging but academically rigorous. Base your corrections *only* on the retrieved documents. Do not mention your tools. Match the language based on the user\'s prompt language';

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
