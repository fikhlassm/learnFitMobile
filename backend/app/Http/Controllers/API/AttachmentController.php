<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessEmbeddings;
use App\Models\Attachment;
use App\Models\StudySession;
use App\Services\DocumentChunker;
use App\Services\DocumentEmbedder;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
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
        Storage::disk('study-materials')->delete($attachment->stored_path);
        $attachment->delete();

        return response()->json([
            'message' => 'Successfully deleted attachment'], 200);
    }
}
