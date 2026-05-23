<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('study_session_attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('study_session_id')->constrained()->cascadeOnDelete();
            $table->uuid('rag_document_id')->nullable();
            $table->string('original_name');
            $table->string('stored_path');
            $table->string('mime_type');
            $table->longText('file_content')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('study_session_attachments');
    }
};
