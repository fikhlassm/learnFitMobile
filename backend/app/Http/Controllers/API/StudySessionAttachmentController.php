<?php

namespace App\Http\Controllers\API;

use Akira\Rag\Facades\Rag;
use App\Http\Controllers\Controller;
use App\Models\StudySession;
use App\Models\StudySessionAttachment;
use App\Services\Rag\IngestionService;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Spatie\PdfToText\Pdf;

class StudySessionAttachmentController extends Controller implements HasMiddleware
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

    public function store(Request $request, StudySession $studySession)
    {
        $request->validate([
            'file' => ['required', 'file', 'max:51200', 'mimes:txt,md,pdf'],
        ]);

        $file = $request->file('file');
        $originalName = $file->getClientOriginalName();
        $mimeType = $file->getMimeType();
        $fileContent = match ($mimeType) {
            'application/pdf' => Pdf::getText($file->getRealPath()),
            default => file_get_contents($file->getRealPath()),
        };

        DB::beginTransaction();

        try {

            $storedPath = $file->store('', 'study-materials');

            $attachment = $studySession->studySessionAttachments()->create([
                'original_name' => $originalName,
                'stored_path' => $storedPath,
                'mime_type' => $mimeType,
                'file_content' => $fileContent,
            ]);

            // ingestion
            $result = Rag::ingest([
                'title' => "{$studySession->topic}",
                'source_type' => 'study_material',
                'source_ref' => "session:{$studySession->id}:attachment:{$attachment->id}",
                'content' => $fileContent,
                'meta' => [
                    'study_session_id' => $studySession->id,
                    'attachment_id' => $attachment->id,
                ],
            ]);

            $attachment->rag_document_id = $result['document_id'];
            $attachment->save();

            DB::commit();

            return response()->json([
                'data' => $attachment,
            ], 201);

        } catch (Exception $e) {
            DB::rollBack();

            if ($storedPath) {
                Storage::disk('study-materials')->delete($storedPath);
            }

            return response()->json([
                'error' => 'Failed to process attachment and ingestion.',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function show(Request $request, StudySession $studySession, StudySessionAttachment $attachment)
    {
        return response()->json([
            'data' => $attachment], 200);
    }

    public function destroy(Request $request, StudySession $studySession, StudySessionAttachment $attachment)
    {
        Storage::disk('study-materials')->delete($attachment->stored_path);
        $attachment->delete();

        return response()->json([
            'message' => 'Successfully deleted attachment'], 200);
    }
}
