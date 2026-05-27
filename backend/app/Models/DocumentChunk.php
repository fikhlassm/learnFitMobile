<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DocumentChunk extends Model
{
    use HasFactory;

    protected $fillable = [
        'source',
        'chunk_text',
        'metadata',
        'embedding',
        'study_session_id',
    ];

    protected function casts(): array
    {
        return [
            'metadata' => 'array',
            'embedding' => 'array',
        ];
    }
}
