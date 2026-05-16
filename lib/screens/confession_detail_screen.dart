// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/playback_manager.dart';
import '../models/confession.dart';
import '../models/comment.dart';
import '../services/appwrite/appwrite_db_service.dart';
import '../services/cloudflare/r2_storage_service.dart';
import '../services/auth_state_service.dart';
import '../models/user.dart';
import '../widgets/comment_bubble.dart';

class ConfessionDetailScreen extends StatefulWidget {
  final Confession confession;

  const ConfessionDetailScreen({super.key, required this.confession});

  @override
  State<ConfessionDetailScreen> createState() => _ConfessionDetailScreenState();
}

class _ConfessionDetailScreenState extends State<ConfessionDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  List<Comment> _comments = [];
  bool _commentsLoading = true;
  late bool _isSaved;
  String? _mockSelectedImagePath;
  bool _isUploadingImage = false;
  bool _isPlayerCollapsed = false;

  @override
  void initState() {
    super.initState();
    final currentUser =
        AuthStateService.instance.currentUser ?? AppUser.fallbackUser;
    final savedIds = currentUser.savedConfessionIds;
    _isSaved =
        savedIds.contains(widget.confession.id) || widget.confession.isSaved;

    _loadComments();

    PlaybackManager().play(widget.confession, context: context, reset: true);

    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 240;
      if (collapsed != _isPlayerCollapsed) {
        setState(() {
          _isPlayerCollapsed = collapsed;
        });
      }
    });
  }

  Future<void> _loadComments() async {
    try {
      final comments = await AppwriteDbService.instance.getComments(
        widget.confession.id,
      );
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (mounted) {
        setState(() {
          _comments = comments;
          _commentsLoading = false;
        });
      }
    } catch (_) {
      final fallback = <Comment>[];
      if (mounted) {
        setState(() {
          _comments = fallback;
          _commentsLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleSave() async {
    final currentUser =
        AuthStateService.instance.currentUser ?? AppUser.fallbackUser;

    final newSaved = !_isSaved;
    setState(() => _isSaved = newSaved);

    try {
      final savedIds = List<String>.from(currentUser.savedConfessionIds);
      if (newSaved) {
        if (!savedIds.contains(widget.confession.id)) {
          savedIds.add(widget.confession.id);
        }
      } else {
        savedIds.remove(widget.confession.id);
      }
      final updatedUser = currentUser.copyWith(savedConfessionIds: savedIds);
      if (AuthStateService.instance.currentUser != null) {
        await AppwriteDbService.instance.updateSavedConfessions(
          currentUser.id,
          savedIds,
        );
        AuthStateService.instance.updateUser(updatedUser);
      } else {
        AppUser.fallbackUser = updatedUser;
      }
    } catch (_) {
      if (mounted) setState(() => _isSaved = !newSaved);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved
                ? 'Saved to your private journal ❤️'
                : 'Confession unsaved',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.pureBlack,
        ),
      );
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty && _mockSelectedImagePath == null) return;

    final currentUser = AuthStateService.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isUploadingImage = true);

    String? finalImageUrl;
    if (_mockSelectedImagePath != null) {
      if (!_mockSelectedImagePath!.startsWith('http') &&
          !_mockSelectedImagePath!.startsWith('journal_snapshot')) {
        try {
          finalImageUrl = await R2StorageService.instance
              .uploadCommentImage(_mockSelectedImagePath!);
        } catch (_) {
          finalImageUrl = _mockSelectedImagePath;
        }
      } else {
        finalImageUrl = _mockSelectedImagePath;
      }
    }

    final newComment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      confessionId: widget.confession.id,
      authorId: currentUser.id,
      content: text.isNotEmpty ? text : 'Shared a visual whisper... 🕯️',
      createdAt: DateTime.now(),
      imageUrl: finalImageUrl,
      isAuthor: widget.confession.authorId == currentUser.id,
    );

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
      _mockSelectedImagePath = null;
      _isUploadingImage = false;
    });
    if (mounted) {
      FocusScope.of(context).unfocus();
    }

    try {
      await AppwriteDbService.instance.createComment(newComment);
      await AppwriteDbService.instance.incrementCommentsCount(
        widget.confession.id,
        widget.confession.commentsCount,
      );
    } catch (_) {}
  }

  Future<void> _deleteComment(Comment comment, int index) async {
    setState(() {
      _comments.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment deleted ❤️'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pureBlack,
      ),
    );
    try {
      if (comment.imageUrl != null && comment.imageUrl!.startsWith('http')) {
        await R2StorageService.instance.deleteImageFile(comment.imageUrl!);
      }
      await AppwriteDbService.instance.deleteComment(comment.id);
      await AppwriteDbService.instance.decrementCommentsCount(widget.confession.id);
    } catch (_) {}
  }

  Future<void> _deleteConfession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Delete Confession Room?'),
        content: const Text(
          'Are you sure you want to permanently delete this confession room? All audio whispers, visual attachments, and comments will be erased.',
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

    if (confirmed != true) return;

    if (mounted) {
      Navigator.pop(context);
    }

    try {
      if (widget.confession.audioUrl != null && widget.confession.audioUrl!.startsWith('http')) {
        await R2StorageService.instance.deleteAudioFile(widget.confession.audioUrl!);
      }
      final comments = await AppwriteDbService.instance.getComments(widget.confession.id);
      for (final c in comments) {
        if (c.imageUrl != null && c.imageUrl!.startsWith('http')) {
          await R2StorageService.instance.deleteImageFile(c.imageUrl!);
        }
        await AppwriteDbService.instance.deleteComment(c.id);
      }
      await AppwriteDbService.instance.deleteConfession(widget.confession.id);
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: ImageSource.gallery);
      if (result != null) {
        setState(() {
          _mockSelectedImagePath = result.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo attached! ❤️'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.pureBlack,
            ),
          );
        }
      }
    } catch (_) {}
  }

  Widget _buildMiniPlayer(PlaybackManager pm) {
    return ListenableBuilder(
      listenable: pm,
      builder: (context, _) {
        final isActive = pm.activeConfession?.id == widget.confession.id;
        final isPlaying = isActive && pm.isPlaying;
        final progress = isActive ? pm.progress : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.pureBlack,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                alignment: Alignment.center,
                child: const Icon(Feather.music, size: 18, color: AppColors.pureBlack),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.confession.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => pm.togglePlay(widget.confession, context: context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pm = PlaybackManager();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.pureBlack,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confession Room',
          style: TextStyle(
            color: AppColors.pureBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: _isSaved ? AppColors.accentRed : AppColors.pureBlack,
            ),
            onPressed: _toggleSave,
          ),
          if (widget.confession.authorId == (AuthStateService.instance.currentUser?.id ?? AppUser.fallbackUser.id))
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.accentRed),
              onPressed: _deleteConfession,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (_isPlayerCollapsed)
            _buildMiniPlayer(pm),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListenableBuilder(
                    listenable: pm,
                    builder: (context, _) {
                      final isActive =
                          pm.activeConfession?.id == widget.confession.id;
                      final isPlaying = isActive && pm.isPlaying;
                      final progress = isActive ? pm.progress : 0.0;

                      return Container(
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: AppColors.divider),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat(
                                    'MMM d, h:mm a',
                                  ).format(widget.confession.createdAt),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Text(
                              widget.confession.title,
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.pureBlack,
                                    height: 1.3,
                                  ),
                            ),
                            const SizedBox(height: 6),

                            FutureBuilder<AppUser?>(
                              future: AppwriteDbService.instance.getUserProfile(
                                widget.confession.authorId,
                              ),
                              builder: (context, snapshot) {
                                final author = snapshot.data;
                                final authorName =
                                    author?.displayName ?? 'Anonymous';
                                final initial = authorName.isNotEmpty
                                    ? authorName[0].toUpperCase()
                                    : 'C';

                                return Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'by $authorName • ${author?.handle ?? ''}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 12),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 28),

                            _buildLargeWaveform(
                              widget.confession.waveformData,
                              progress,
                            ),
                            const SizedBox(height: 14),

                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                activeTrackColor: AppColors.pureBlack,
                                inactiveTrackColor: AppColors.divider,
                                thumbColor: AppColors.pureBlack,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5.0,
                                ),
                                overlayColor: AppColors.pureBlack.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                              child: Slider(
                                value: progress,
                                onChanged: (val) {
                                  if (isActive) {
                                    pm.seek(val);
                                  } else {
                                    pm.play(
                                      widget.confession,
                                      context: context,
                                    );
                                    pm.seek(val);
                                  }
                                },
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isActive ? pm.elapsedString : '0:00',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  widget.confession.durationString,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10, size: 28),
                                  onPressed: () {
                                    if (isActive) {
                                      pm.seek(
                                        (progress - 0.05).clamp(0.0, 1.0),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 14),
                                GestureDetector(
                                  onTap: () => pm.togglePlay(
                                    widget.confession,
                                    context: context,
                                  ),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.pureBlack,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: pm.isBuffering && isActive
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(
                                            isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: AppColors.cardBg,
                                            size: 32,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                IconButton(
                                  icon: const Icon(Icons.forward_10, size: 28),
                                  onPressed: () {
                                    if (isActive) {
                                      pm.seek(
                                        (progress + 0.05).clamp(0.0, 1.0),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Text(
                        'Comments ❤️',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pureBlack,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${_comments.length} comments',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Builder(
                    builder: (context) {
                      final displayComments =
                          _commentsLoading && _comments.isEmpty
                          ? List.generate(
                              3,
                              (i) => Comment(
                                id: 'mock_$i',
                                confessionId: widget.confession.id,
                                authorId: 'user_guest',
                                content:
                                    'This is a mock whisper comment for skeleton layout loading...',
                                createdAt: DateTime.now(),
                                isAuthor: false,
                              ),
                            )
                          : _comments;

                      if (displayComments.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: Text(
                            'No comments yet. Be the first to say something ❤️',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                          ),
                        );
                      }

                      return Skeletonizer(
                        enabled: _commentsLoading,
                        containersColor: AppColors.cardBg,
                        effect: const ShimmerEffect(
                          baseColor: Color(0xFFDFDAD4),
                          highlightColor: Color(0xFFF0EDE9),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayComments.length,
                          itemBuilder: (context, index) {
                            final comment = displayComments[index];
                            final currentUserId = AuthStateService.instance.currentUser?.id ?? AppUser.fallbackUser.id;
                            final showDelete = comment.authorId == currentUserId || widget.confession.authorId == currentUserId;

                            return CommentBubble(
                              comment: comment,
                              onDelete: showDelete && !_commentsLoading
                                  ? (c) => _deleteComment(c, index)
                                  : null,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              border: const Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_mockSelectedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Feather.image,
                                size: 14,
                                color: AppColors.pureBlack,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Image',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _mockSelectedImagePath = null,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColors.accentRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    if (widget.confession.authorId ==
                        (AuthStateService.instance.currentUser?.id ??
                            AppUser.fallbackUser.id)) ...[
                      GestureDetector(
                        onTap: _isUploadingImage ? null : _pickImage,
                        child: const Icon(
                          Feather.image,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        cursorColor: AppColors.pureBlack,
                        style: const TextStyle(fontSize: 13.5),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _isUploadingImage ? null : _addComment,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.pureBlack,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: _isUploadingImage
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeWaveform(List<double> data, double progress) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(data.length, (index) {
          final barProgress = index / data.length;
          final isFilled = barProgress <= progress;

          return Expanded(
            child: Container(
              height: data[index] * 60,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: isFilled
                    ? AppColors.pureBlack
                    : AppColors.textSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
