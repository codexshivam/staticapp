import 'package:appwrite/appwrite.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AppwriteExceptionMapped implements Exception {
  final String message;
  final int? code;
  final String? type;

  AppwriteExceptionMapped({required this.message, this.code, this.type});

  @override
  String toString() => message;
}

class AppwritePerformanceHelper {
  AppwritePerformanceHelper._();

  static Future<T> traceAndHandle<T>({
    required String traceName,
    required Future<T> Function() operation,
  }) async {
    final trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();
      debugPrint('[Appwrite Performance] Trace "$traceName" finished in ${stopwatch.elapsedMilliseconds}ms');
      await trace.stop();
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      await trace.stop();

      if (e is AppwriteException) {
        debugPrint('[Appwrite Exception] Trace "$traceName" failed: Code ${e.code}, Type ${e.type}, Message: ${e.message}');
        
        try {
          await FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'Appwrite Exception in "$traceName": ${e.message}',
            fatal: false,
          );
        } catch (crErr) {
          debugPrint('Crashlytics logging failure: $crErr');
        }

        String friendlyMessage = 'Something went wrong. Please try again.';
        switch (e.code) {
          case 400:
            friendlyMessage = e.message?.contains('password') == true
                ? 'Password is invalid. It must be at least 8 characters.'
                : 'Invalid request input. Please check field validation.';
            break;
          case 401:
            friendlyMessage = 'Unauthorized. Please sign in again to continue.';
            break;
          case 403:
            friendlyMessage = 'Access denied. You do not have permissions for this action.';
            break;
          case 404:
            friendlyMessage = 'Requested content or document could not be found.';
            break;
          case 409:
            friendlyMessage = e.type == 'user_already_exists'
                ? 'An account with this email address already exists.'
                : 'Conflict occurred. This username/handle may already be taken.';
            break;
          default:
            if (e.message != null && e.message!.isNotEmpty) {
              friendlyMessage = e.message!;
            }
            break;
        }

        throw AppwriteExceptionMapped(
          message: friendlyMessage,
          code: e.code,
          type: e.type,
        );
      } else {
        debugPrint('[Appwrite Unknown Error] Trace "$traceName" failed: $e');
        
        try {
          await FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'Unknown error inside "$traceName"',
            fatal: false,
          );
        } catch (crErr) {
          debugPrint('Crashlytics logging failure: $crErr');
        }
        rethrow;
      }
    }
  }
}
