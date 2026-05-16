import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;

/// Cloudflare R2 storage service using direct S3 API uploads with AWS4 signatures.
class R2StorageService {
  static final R2StorageService instance = R2StorageService._();
  R2StorageService._();

  String? _accessKeyId;
  String? _secretAccessKey;
  String? _endpoint;
  String? _bucketName;
  String? _publicUrl;
  String? _host;
  Dio? _dio;

  void initialize() {
    _accessKeyId = dotenv.env['R2_ACCESS_KEY_ID'] ?? '';
    _secretAccessKey = dotenv.env['R2_SECRET_ACCESS_KEY'] ?? '';
    _endpoint = dotenv.env['R2_ENDPOINT'] ?? '';
    _bucketName = dotenv.env['R2_BUCKET'] ?? '';
    _publicUrl = dotenv.env['R2_PUBLIC_URL'] ?? '';

    if (_accessKeyId!.isEmpty || _secretAccessKey!.isEmpty || _endpoint!.isEmpty || _bucketName!.isEmpty) {
      debugPrint('[R2] Incomplete configuration — storage disabled');
      return;
    }

    // Extract host from endpoint (e.g., "7f4b97a2565849ad980c9401fb2fc427.r2.cloudflarestorage.com")
    try {
      _host = Uri.parse(_endpoint!).host;
    } catch (_) {
      debugPrint('[R2] Invalid endpoint URL');
      return;
    }

    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  bool get isConfigured => _accessKeyId != null && _host != null && _dio != null;

  void _checkConfigured() {
    if (!isConfigured) {
      throw R2Exception('R2 storage not configured.');
    }
  }

  /// Upload bytes to R2 and return the public URL
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String path,
    required String contentType,
  }) async {
    _checkConfigured();
    if (bytes.isEmpty) {
      throw R2Exception('Cannot upload empty file.');
    }
    if (path.trim().isEmpty) {
      throw R2Exception('Upload path cannot be empty.');
    }

    try {
      final url = '$_endpoint/$_bucketName/$path';
      final now = DateTime.now().toUtc();
      final dateStamp = _formatDate(now);
      final amzDate = _formatAmzDate(now);
      final cacheControl = 'public, max-age=31536000, immutable';

      final payloadHash = sha256.convert(bytes).toString();

      final headers = _generateAuthHeaders(
        method: 'PUT',
        path: '/$_bucketName/$path',
        contentType: contentType,
        date: dateStamp,
        amzDate: amzDate,
        payloadHash: payloadHash,
        cacheControl: cacheControl,
      );

      await _dio!.put(url,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            ...headers,
            'Content-Type': contentType,
            'Content-Length': bytes.length,
            'Cache-Control': cacheControl,
          },
        ),
      );

      return _publicUrl != null ? '$_publicUrl/$path' : url;
    } on DioException catch (e) {
      throw R2Exception('Upload failed: ${_dioErrorMessage(e)}');
    }
  }

  Future<String> uploadConfessionAudio(String localPath) async {
    final file = File(localPath);
    final bytes = await file.readAsBytes();
    final ext = p.extension(localPath);
    final contentType = _mimeType(ext);
    final key = 'confessions/audio_${DateTime.now().millisecondsSinceEpoch}$ext';
    
    return uploadBytes(bytes: bytes, path: key, contentType: contentType);
  }

  Future<String> uploadCommentImage(String localPath) async {
    final file = File(localPath);
    final bytes = await file.readAsBytes();
    final ext = p.extension(localPath);
    final contentType = _mimeType(ext);
    final key = 'comments/image_${DateTime.now().millisecondsSinceEpoch}$ext';
    
    return uploadBytes(bytes: bytes, path: key, contentType: contentType);
  }

  Future<void> deleteFile(String fileUrl) async {
    _checkConfigured();
    if (_publicUrl == null || !fileUrl.startsWith(_publicUrl!)) return;
    
    final path = fileUrl.replaceFirst('$_publicUrl!/', '');
    if (path.isEmpty) return;

    try {
      final url = '$_endpoint/$_bucketName/$path';
      final now = DateTime.now().toUtc();
      final dateStamp = _formatDate(now);
      final amzDate = _formatAmzDate(now);
      
      final payloadHash = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

      final headers = _generateAuthHeaders(
        method: 'DELETE',
        path: '/$_bucketName/$path',
        contentType: '',
        date: dateStamp,
        amzDate: amzDate,
        payloadHash: payloadHash,
      );

      await _dio!.delete(url,
        options: Options(
          headers: headers,
        ),
      );
    } catch (_) {}
  }

  Future<void> deleteAudioFile(String fileUrl) => deleteFile(fileUrl);
  Future<void> deleteImageFile(String fileUrl) => deleteFile(fileUrl);

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

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Upload timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 403) return 'Access denied. Check R2 credentials.';
        if (status == 404) return 'R2 bucket not found. Check configuration.';
        if (status != null && status >= 500) return 'R2 service unavailable. Try later.';
        return 'R2 error (HTTP $status).';
      default:
        return e.message ?? 'Unknown upload error.';
    }
  }

  Map<String, String> _generateAuthHeaders({
    required String method,
    required String path,
    required String contentType,
    required String date,
    required String amzDate,
    required String payloadHash,
    String? cacheControl,
  }) {
    final region = 'auto';
    final service = 's3';
    final scope = '$date/$region/$service/aws4_request';

    String canonicalHeaders;
    String signedHeaders;

    if (cacheControl != null) {
      canonicalHeaders = 'cache-control:$cacheControl\n'
          'content-type:$contentType\n'
          'host:$_host\n'
          'x-amz-content-sha256:$payloadHash\n'
          'x-amz-date:$amzDate\n';
      signedHeaders = 'cache-control;content-type;host;x-amz-content-sha256;x-amz-date';
    } else {
      canonicalHeaders = contentType.isNotEmpty ? 'content-type:$contentType\n' : '';
      canonicalHeaders += 'host:$_host\n'
          'x-amz-content-sha256:$payloadHash\n'
          'x-amz-date:$amzDate\n';
      
      signedHeaders = contentType.isNotEmpty 
          ? 'content-type;host;x-amz-content-sha256;x-amz-date'
          : 'host;x-amz-content-sha256;x-amz-date';
    }

    final canonicalRequest = '$method\n$path\n\n$canonicalHeaders\n$signedHeaders\n$payloadHash';
    final stringToSign = 'AWS4-HMAC-SHA256\n$amzDate\n$scope\n${sha256.convert(utf8.encode(canonicalRequest))}';

    final signingKey = _getSignatureKey(date, region, service);
    final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    return {
      'Authorization': 'AWS4-HMAC-SHA256 Credential=$_accessKeyId/$scope, SignedHeaders=$signedHeaders, Signature=$signature',
      'x-amz-date': amzDate,
      'x-amz-content-sha256': payloadHash,
    };
  }

  List<int> _getSignatureKey(String date, String region, String service) {
    final kDate = Hmac(sha256, utf8.encode('AWS4$_secretAccessKey')).convert(utf8.encode(date)).bytes;
    final kRegion = Hmac(sha256, kDate).convert(utf8.encode(region)).bytes;
    final kService = Hmac(sha256, kRegion).convert(utf8.encode(service)).bytes;
    return Hmac(sha256, kService).convert(utf8.encode('aws4_request')).bytes;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';

  String _formatAmzDate(DateTime dt) =>
      '${_formatDate(dt)}T${dt.hour.toString().padLeft(2, '0')}${dt.minute.toString().padLeft(2, '0')}${dt.second.toString().padLeft(2, '0')}Z';
}

class R2Exception implements Exception {
  final String message;
  const R2Exception(this.message);
  @override
  String toString() => message;
}
