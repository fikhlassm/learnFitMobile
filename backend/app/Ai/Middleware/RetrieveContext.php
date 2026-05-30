<?php

namespace App\Ai\Middleware;

use App\Models\DocumentChunk;
use Closure;
use Laravel\Ai\Prompts\AgentPrompt;

class RetrieveContext
{
    public function __construct(
        protected float $minSimilarity = 0.3,
        protected int $limit = 10,
    ) {}

    public function handle(AgentPrompt $prompt, Closure $next)
    {
        $agent = $prompt->agent;

        if (! isset($agent->studySessionId)) {
            return $next($prompt);
        }

        $chunks = DocumentChunk::query()
            ->where('study_session_id', $agent->studySessionId)
            ->whereVectorSimilarTo('embedding', $prompt->prompt, $this->minSimilarity)
            ->limit($this->limit)
            ->get();

        $prompt->agent->withChunks($chunks);

        return $next($prompt);
    }
}
