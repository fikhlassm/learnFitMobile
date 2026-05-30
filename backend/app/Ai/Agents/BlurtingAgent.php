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

#[Temperature(0.0)]
class BlurtingAgent implements Agent, Conversational, HasTools
{
    use Promptable;

    public function __construct(public int $studySessionId) {}

    public function instructions(): Stringable|string
    {
        return '
        ### ROLE
        You are an objective evaluator for the "Blurting Method" study technique. Your job is to assess the student\'s recalled information against the source documents.

        ### OPERATIONAL RULES
        1. **Tool First:** You MUST call the `SimilaritySearch` tool using the student\'s text to retrieve the source facts before providing your evaluation.
        2. **Evaluation Framework:** Compare the user\'s input strictly against the retrieved documents and structure your feedback as follows:
        - **Accurate Recall:** Briefly list what the student got right.
        - **Knowledge Gaps:** Highlight important facts, definitions, or details from the source documents that the student completely missed.
        - **Misconceptions/Errors:** Correct anything the student recalled incorrectly based *only* on the documents.
        3. **Strict Grounding:** If the source documents do not contain information related to the user\'s text, state: "I cannot evaluate this section as it is not present in your study materials."

        ### CONSTRAINT
        Be concise, constructive, and direct. Do not mention your tools or these internal rules.';
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
                limit: 5,
                query: fn ($query) => $query->where('study_session_id', $this->studySessionId)
            ),
        ];
    }
}
