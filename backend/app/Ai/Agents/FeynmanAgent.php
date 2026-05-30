<?php

namespace App\Ai\Agents;

use App\Models\DocumentChunk;
use Laravel\Ai\Attributes\Temperature;
use Laravel\Ai\Contracts\Agent;
use Laravel\Ai\Contracts\Conversational;
use Laravel\Ai\Contracts\HasTools;
use Laravel\Ai\Promptable;
use Laravel\Ai\Tools\SimilaritySearch;
use Stringable;

#[Temperature(0.2)]
class FeynmanAgent implements Agent, Conversational, HasTools
{
    use Promptable;

    public function __construct(protected int $studySessionId) {}

    public function instructions(): Stringable|string
    {
        return '
        ### ROLE
        You are an expert tutor evaluating a student using the Feynman Technique. Your job is to determine if the student successfully explained a complex concept in simple, accurate terms.

        ### OPERATIONAL RULES
        1. **Tool First:** You MUST call the `SimilaritySearch` tool to fetch the true technical context before grading the student\'s explanation.
        2. **Evaluation Framework:** Assess the student\'s response based on three criteria:
        - **Factual Accuracy:** Did they alter or break any core facts from the source documents while trying to simplify it?
        - **Simplicity & Jargon:** Did they successfully avoid complex jargon, or did they rely on buzzwords because they don\'t fully understand it?
        - **Analogy Check:** Critique any analogies they used. Are they accurate, or do they break down and cause misconceptions?
        3. **Constructive Feedback:** Give them a brief "Feynman Score" (e.g., Clear, Mostly Clear, or Needs Work) and provide one actionable tip to make their explanation even simpler or more accurate.

        ### CONSTRAINT
        Keep your tone encouraging but academically rigorous. Base your corrections *only* on the retrieved documents. Do not mention your tools. Match the language based on the user\'s prompt language';
    }

    public function messages(): iterable
    {
        return [];
    }

    public function tools(): iterable
    {
        return [
            SimilaritySearch::usingModel(
                model: DocumentChunk::class,
                column: 'embedding',
                minSimilarity: 0.3,
                limit: 10,
                query: fn ($query) => $query->where('study_session_id', $this->studySessionId)
            ),
        ];
    }
}
