<?php

use App\Models\Attachment;
use App\Models\DocumentChunk;
use App\Models\StudySession;
use App\Models\StudyTechnique;
use App\Models\User;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;

/*
 | These tests build only the tables the attachment/evaluation flow needs.
 | The real document_chunks migration relies on the pgvector extension, which
 | isn't available under the sqlite test driver — so we recreate a compatible
 | shape here (embedding as plain text) to still exercise the JSON-metadata
 | cleanup query end-to-end.
 */
beforeEach(function () {
    foreach (['document_chunks', 'attachments', 'study_sessions', 'study_techniques', 'users'] as $table) {
        Schema::dropIfExists($table);
    }

    Schema::create('users', function ($table) {
        $table->id();
        $table->string('name');
        $table->string('email')->unique();
        $table->timestamp('email_verified_at')->nullable();
        $table->string('password')->nullable();
        $table->rememberToken();
        $table->timestamps();
    });

    Schema::create('study_techniques', function ($table) {
        $table->id();
        $table->string('name');
        $table->text('description')->nullable();
        $table->timestamps();
    });

    Schema::create('study_sessions', function ($table) {
        $table->id();
        $table->foreignId('user_id');
        $table->foreignId('study_technique_id');
        $table->string('topic', 50);
        $table->text('content')->nullable();
        $table->timestamps();
    });

    Schema::create('attachments', function ($table) {
        $table->id();
        $table->foreignId('study_session_id');
        $table->string('file_name');
        $table->string('stored_path');
        $table->string('mime_type');
        $table->timestamps();
    });

    Schema::create('document_chunks', function ($table) {
        $table->id();
        $table->integer('study_session_id');
        $table->string('source');
        $table->text('chunk_text');
        $table->json('metadata')->nullable();
        $table->text('embedding')->nullable();
        $table->timestamps();
    });
});

/** Creates a session owned by $user for the given technique name. */
function makeSession(User $user, string $technique = 'blurting'): StudySession
{
    $tech = StudyTechnique::create(['name' => $technique, 'description' => '']);

    return StudySession::create([
        'user_id' => $user->id,
        'study_technique_id' => $tech->id,
        'topic' => 'Struktur Sel',
    ]);
}

it('deletes attachment record, storage file, and its document chunks', function () {
    Storage::fake('study-materials');
    $user = User::factory()->create();
    Sanctum::actingAs($user);

    $session = makeSession($user);

    Storage::disk('study-materials')->put('material.txt', 'contents');
    $attachment = Attachment::create([
        'study_session_id' => $session->id,
        'file_name' => 'material.txt',
        'stored_path' => 'material.txt',
        'mime_type' => 'text/plain',
    ]);

    // Two chunks belong to this attachment; one belongs to a different one and
    // must survive to prove the delete is scoped, not a blanket wipe.
    DocumentChunk::create([
        'study_session_id' => $session->id,
        'source' => 'material.txt',
        'chunk_text' => 'chunk a',
        'metadata' => ['attachment_id' => $attachment->id],
        'embedding' => '[]',
    ]);
    DocumentChunk::create([
        'study_session_id' => $session->id,
        'source' => 'material.txt',
        'chunk_text' => 'chunk b',
        'metadata' => ['attachment_id' => $attachment->id],
        'embedding' => '[]',
    ]);
    DocumentChunk::create([
        'study_session_id' => $session->id,
        'source' => 'other.txt',
        'chunk_text' => 'unrelated',
        'metadata' => ['attachment_id' => $attachment->id + 999],
        'embedding' => '[]',
    ]);

    $response = $this->deleteJson("/api/study-sessions/{$session->id}/attachments/{$attachment->id}");

    $response->assertOk();

    // Record gone, storage object gone, no orphaned chunks for this attachment.
    $this->assertDatabaseMissing('attachments', ['id' => $attachment->id]);
    Storage::disk('study-materials')->assertMissing('material.txt');
    expect(DocumentChunk::where('metadata->attachment_id', $attachment->id)->count())->toBe(0);
    // The unrelated chunk is untouched.
    expect(DocumentChunk::count())->toBe(1);
});

it('does not error when the stored file is already missing (no orphaned record)', function () {
    Storage::fake('study-materials');
    $user = User::factory()->create();
    Sanctum::actingAs($user);

    $session = makeSession($user);
    $attachment = Attachment::create([
        'study_session_id' => $session->id,
        'file_name' => 'gone.txt',
        'stored_path' => 'gone.txt', // never actually stored
        'mime_type' => 'text/plain',
    ]);

    $this->deleteJson("/api/study-sessions/{$session->id}/attachments/{$attachment->id}")
        ->assertOk();

    $this->assertDatabaseMissing('attachments', ['id' => $attachment->id]);
});

it('forbids deleting an attachment owned by another user', function () {
    Storage::fake('study-materials');
    $owner = User::factory()->create();
    $session = makeSession($owner);
    $attachment = Attachment::create([
        'study_session_id' => $session->id,
        'file_name' => 'material.txt',
        'stored_path' => 'material.txt',
        'mime_type' => 'text/plain',
    ]);

    Sanctum::actingAs(User::factory()->create()); // a different user

    $this->deleteJson("/api/study-sessions/{$session->id}/attachments/{$attachment->id}")
        ->assertNotFound();

    $this->assertDatabaseHas('attachments', ['id' => $attachment->id]);
});

it('rejects evaluation text shorter than 3 characters', function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user);
    $session = makeSession($user, 'blurting');

    $this->postJson("/api/study-sessions/{$session->id}/evaluate", ['text' => 'hi'])
        ->assertStatus(422)
        ->assertJsonValidationErrors('text');
});

it('accepts evaluation text of at least 3 characters (passes validation)', function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user);
    $session = makeSession($user, 'blurting');

    // The AI service is unavailable in tests, but the request must clear the
    // validation layer — so we assert it is NOT a 422 validation failure.
    $response = $this->postJson("/api/study-sessions/{$session->id}/evaluate", ['text' => 'sel']);

    expect($response->status())->not->toBe(422);
});
