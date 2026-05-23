<?php

declare(strict_types=1);

use Akira\Rag\Models\RagChunk;
use Akira\Rag\Models\RagDocument;
use Akira\Rag\Models\RagEmbedding;
use Akira\Rag\Models\RagQuery;
use Akira\Rag\Observability\LogMetricsRecorder;
use Akira\Rag\Tenant\NullTenantResolver;

return [

    /*
    |--------------------------------------------------------------------------
    | Tenancy
    |--------------------------------------------------------------------------
    |
    | Configure single-tenant or multi-tenant behavior. When disabled, the
    | tenant column remains null and no resolver is used. When enabled, the
    | resolver returns the current tenant identifier.
    */
    'tenancy' => [
        'enabled' => env('RAG_TENANCY_ENABLED', true),
        'resolver' => NullTenantResolver::class,
        'tenant_column' => 'tenant_id',
    ],

    /*
    |--------------------------------------------------------------------------
    | Models
    |--------------------------------------------------------------------------
    |
    | The Eloquent models used by the package. You may swap these with your
    | own models as long as the schema stays compatible.
    */
    'models' => [
        'document' => RagDocument::class,
        'chunk' => RagChunk::class,
        'embedding' => RagEmbedding::class,
        'query' => RagQuery::class,
    ],

    /*
    |--------------------------------------------------------------------------
    | AI Models
    |--------------------------------------------------------------------------
    |
    | Default identifiers for embedding, chat, and reranking. These are names
    | only; configure your actual provider separately.
    */
    'ai' => [
        'embedding_model' => env('RAG_EMBEDDING_MODEL', 'text-embedding-3-small'),
        'chat_model' => env('RAG_CHAT_MODEL', 'gpt-4'),
        'rerank_model' => 'gpt-4.1-mini',
    ],

    /*
    |--------------------------------------------------------------------------
    | Chunking
    |--------------------------------------------------------------------------
    |
    | Token-based chunking settings. Overlap preserves context between adjacent
    | chunks during retrieval.
    */
    'chunking' => [
        'target_tokens' => env('RAG_CHUNK_TARGET_TOKENS', 800),
        'overlap_tokens' => env('RAG_CHUNK_OVERLAP_TOKENS', 120),
    ],

    /*
    |--------------------------------------------------------------------------
    | Retrieval
    |--------------------------------------------------------------------------
    |
    | top_k controls final chunks returned; candidate_k controls intermediate
    | candidates. Hybrid retrieval blends semantic and keyword scoring. The
    | ts_config controls PostgreSQL text search configuration.
    */
    'retrieval' => [
        'top_k' => env('RAG_RETRIEVAL_TOP_K', 5),

        'hybrid' => [
            'enabled' => env('RAG_HYBRID_ENABLED', true),
            'semantic_weight' => env('RAG_HYBRID_SEMANTIC_WEIGHT', 0.75),
            'keyword_weight' => env('RAG_HYBRID_KEYWORD_WEIGHT', 0.25),
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Prompt
    |--------------------------------------------------------------------------
    |
    | Default system prompt and language used when constructing chat requests.
    */
    'prompt' => [
        'system' => 'You MUST answer only using the provided context. If the answer is not present, say so clearly.',
        'language' => 'en',
    ],

    /*
    |--------------------------------------------------------------------------
    | Cache
    |--------------------------------------------------------------------------
    |
    | Enables response caching for Rag::ask. TTL is in seconds; prefix namespaces
    | cache entries.
    */
    'cache' => [
        'enabled' => env('RAG_CACHE_ENABLED', true),
        'prefix' => env('RAG_CACHE_PREFIX', 'rag:v1'),
        'ttl_seconds' => env('RAG_CACHE_TTL_SECONDS', 1209600), // 14 days
    ],

    /*
    |--------------------------------------------------------------------------
    | Audit
    |--------------------------------------------------------------------------
    |
    | When enabled, queries and retrieved chunks are stored. Use store_prompts
    | to persist prompts when appropriate.
    */
    'audit' => [
        'enabled' => env('RAG_AUDIT_ENABLED', true),
    ],

    /*
    |--------------------------------------------------------------------------
    | Queue
    |--------------------------------------------------------------------------
    |
    | Connection and queue name for background work. Null values fall back to
    | your application defaults.
    */
    'queue' => [
        'connection' => null,
        'queue' => null,
    ],

    /*
    |--------------------------------------------------------------------------
    | Observability
    |--------------------------------------------------------------------------
    |
    | Configure structured logging and metrics collection for RAG operations.
    | Logs are written to the configured channel. Metrics are recorded via the
    | provided recorder implementation.
    */
    'observability' => [
        'logging' => [
            'enabled' => true,
            'channel' => 'rag',
        ],
        'metrics' => [
            'enabled' => true,
            'recorder' => LogMetricsRecorder::class,
        ],
    ],
];
