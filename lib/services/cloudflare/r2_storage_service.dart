import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cloudflare R2 storage service.
/// 
/// Upload strategy — zero egress cost:
///   • Files are PUT to a Cloudflare Worker endpoint (or pre-signed R2 URL)
///     which writes directly to R2.
///   • The public CDN URL (R2_PUBLIC_URL) is returned and stored in the DB —
///     reads are served by Cloudflare edge, never hitting the origin.
/// 
/// Cost reduction:
///   • R2 has no egress fees — reads are free for users all around the world.
///   • Large files (audio) are uploaded once and never re-uploaded unless deleted.
///   • Comment images are compressed client-side before upload (future improvement).
class R2StorageService {
  static final R2StorageService instance = R2StorageService._();
  R2StorageService._();

  String get _uploadUrl => dotenv.env['R2_UPLOAD_URL'] ?? '';
  String get _publicUrl => dotenv.env['R2_PUBLIC_URL'] ?? '';

  /// Upload a file to R2 via the configured Worker endpoint.
  /// Returns the public CDN URL for the uploaded file.
  Future<String> _uploadFile(String localPath, String remoteKey) async {
    final file = File(localPath);
    final bytes = await file.readAsBytes();
    final ext = p.extension(localPath);

    final contentType = _mimeType(ext);

    final uri = Uri.parse('$_uploadUrl/$remoteKey');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': contentType,
        'Content-Length': bytes.length.toString(),
      },
      body: bytes,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('R2 upload failed: ${response.statusCode} ${response.body}');
    }

    return '$_publicUrl/$remoteKey';
  }

  String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case '.m4a':
        return 'audio/mp4';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  // ─── PUBLIC API ───────────────────────────────────────────────────────────

  Future<String> uploadConfessionAudio(String localPath) async {
    final ext = p.extension(localPath);
    final key = 'confessions/audio_${DateTime.now().millisecondsSinceEpoch}$ext';
    return _uploadFile(localPath, key);
  }

  Future<String> uploadCommentImage(String localPath) async {
    final ext = p.extension(localPath);
    final key = 'comments/image_${DateTime.now().millisecondsSinceEpoch}$ext';
    return _uploadFile(localPath, key);
  }

  /// Soft-delete via Worker DELETE endpoint — no-op if Worker doesn't support it.
  Future<void> deleteFile(String fileUrl) async {
    try {
      if (!fileUrl.startsWith(_publicUrl)) return;
      final key = fileUrl.replaceFirst('$_publicUrl/', '');
      final uri = Uri.parse('$_uploadUrl/$key');
      await http.delete(uri);
    } catch (_) {}
  }

  Future<void> deleteAudioFile(String fileUrl) => deleteFile(fileUrl);
  Future<void> deleteImageFile(String fileUrl) => deleteFile(fileUrl);
}
