<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Attachment;
use App\Models\DocumentChunk;
use App\Models\StudySession;
use App\Services\DocumentChunker;
use App\Services\DocumentEmbedder;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Spatie\PdfToText\Pdf;

class AttachmentController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware('can:modify,study_session', only: ['store', 'index']),
            new Middleware('can:modify,attachment', only: ['show', 'destroy']),
        ];
    }

    public function index(Request $request, StudySession $studySession)
    {
        $attachments = $studySession->studySessionAttachments()->get();

        return response()->json([
            'data' => $attachments], 200);
    }

    public function store(Request $request, StudySession $studySession, DocumentChunker $chunker, DocumentEmbedder $embeddingService)
    {
        $request->validate([
            'file' => ['required', 'file', 'max:51200', 'mimes:txt,md,pdf'],
        ]);

        $file = $request->file('file');
        $fileName = $file->getClientOriginalName();
        $mimeType = $file->getMimeType();
        $storedPath = null;
        $fileContent = match ($mimeType) {
            'application/pdf' => Pdf::getText($file->getRealPath()),
            default => file_get_contents($file->getRealPath()),
        };

        try {
            $storedPath = $file->store('', 'study-materials');

            $attachment = $studySession->studySessionAttachments()->create([
                'file_name' => $fileName,
                'stored_path' => $storedPath,
                'mime_type' => $mimeType,
            ]);

            // ingestion
            $chunks = $chunker->chunk($fileName, $fileContent);
            $embeddingService->process($attachment, $chunks);

            return response()->json([
                'data' => $attachment,
            ], 201);

        } catch (Exception $e) {

            if ($storedPath) {
                Storage::disk('study-materials')->delete($storedPath);
            }

            return response()->json([
                'error' => 'Failed to process attachment.',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function show(Request $request, StudySession $studySession, Attachment $attachment)
    {
        return response()->json([
            'data' => $attachment], 200);
    }

    public function destroy(Request $request, StudySession $studySession, Attachment $attachment)
    {
        // Remove the DB record and its derived document chunks atomically so no
        // orphaned rows survive if something fails midway.
        DB::transaction(function () use ($attachment) {
            DocumentChunk::query()
                ->where('study_session_id', $attachment->study_session_id)
                ->where('metadata->attachment_id', $attachment->id)
                ->delete();

            $attachment->delete();
        });

        // Storage cleanup happens after the record is gone; guard against a
        // missing/blank path so a re-delete or partial upload can't error.
        if ($attachment->stored_path && Storage::disk('study-materials')->exists($attachment->stored_path)) {
            Storage::disk('study-materials')->delete($attachment->stored_path);
        }

        return response()->json([
            'message' => 'Successfully deleted attachment'], 200);
    }
}
