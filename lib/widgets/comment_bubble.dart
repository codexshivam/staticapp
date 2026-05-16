import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../services/appwrite/appwrite_db_service.dart';

class CommentBubble extends StatelessWidget {
  final Comment comment;
  final void Function(Comment)? onDelete;

  const CommentBubble({
    super.key,
    required this.comment,
    this.onDelete,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: comment.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied confession whisper to clipboard ❤️'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  Widget _buildFallbackImagePlaceholder(BuildContext context, String text) {
    return Container(
      height: 150,
      width: double.infinity,
      color: AppColors.background,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_outlined,
            color: AppColors.textSecondary,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: AppwriteDbService.instance.getUserProfile(comment.authorId),
      builder: (context, snapshot) {
        final author = snapshot.data;
        final authorName = author?.displayName ?? 'Anonymous';
        final initial = authorName.isNotEmpty ? authorName[0].toUpperCase() : 'C';
        final timeAgo = _getRelativeTime(comment.createdAt);

        return Container(
          margin: const EdgeInsets.only(bottom: 14.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authorName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (comment.isAuthor)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: const Text(
                        'Author ❤️',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    timeAgo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyToClipboard(context),
                    child: const Icon(
                      Icons.copy,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.cardBg,
                            title: const Text('Delete Comment?'),
                            content: const Text(
                              'Are you sure you want to delete this whisper comment?',
                              style: TextStyle(fontSize: 14),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel', style: TextStyle(color: AppColors.pureBlack)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          onDelete!(comment);
                        }
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: AppColors.accentRed,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comment.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              if (comment.imageUrl != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenPhotoScreen(imageUrl: comment.imageUrl!),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (comment.imageUrl!.startsWith('http'))
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 320),
                            child: CachedNetworkImage(
                              imageUrl: comment.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 150,
                                width: double.infinity,
                                color: AppColors.background,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(color: AppColors.pureBlack),
                              ),
                              errorWidget: (context, url, error) => _buildFallbackImagePlaceholder(context, comment.imageUrl!),
                            ),
                          )
                        else if (comment.imageUrl!.startsWith('/'))
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 320),
                            child: Image.file(
                              File(comment.imageUrl!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildFallbackImagePlaceholder(context, comment.imageUrl!),
                            ),
                          )
                        else
                          _buildFallbackImagePlaceholder(context, comment.imageUrl!),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.pureBlack.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'Attached Whisper Photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(time);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class FullScreenPhotoScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenPhotoScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureBlack,
      appBar: AppBar(
        backgroundColor: AppColors.pureBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Whisper Photo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: imageUrl.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                  errorWidget: (context, url, error) => const Icon(Icons.image, size: 100, color: Colors.white),
                )
              : imageUrl.startsWith('/')
                  ? Image.file(File(imageUrl), fit: BoxFit.contain)
                  : const Icon(Icons.image, size: 100, color: Colors.white),
        ),
      ),
    );
  }
}
