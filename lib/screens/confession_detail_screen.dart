// ignore_for_file: unused_element

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/playback_manager.dart';
import '../models/confession.dart';
import '../models/comment.dart';
import '../mock_data/sample_data.dart';
import '../services/appwrite/appwrite_db_service.dart';
import '../services/auth_state_service.dart';
import '../services/user_cache_service.dart';
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
  List<Comment> _comments = [];
  bool _commentsLoading = true;
  late bool _isSaved;
  String? _mockSelectedImagePath;

  @override
  void initState() {
    super.initState();
    final currentUser = AuthStateService.instance.currentUser;
    final savedIds = currentUser?.savedConfessionIds ?? [];
    _isSaved = savedIds.contains(widget.confession.id);

    _loadComments();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PlaybackManager().play(widget.confession, context: context);
    });
  }

  Future<void> _loadComments() async {
    try {
      final comments = await AppwriteDbService.instance.getComments(
        widget.confession.id,
      );
      if (mounted)
        setState(() {
          _comments = comments;
          _commentsLoading = false;
        });
    } catch (_) {
      final fallback = List<Comment>.from(
        SampleData.mockComments[widget.confession.id] ?? [],
      );
      if (mounted)
        setState(() {
          _comments = fallback;
          _commentsLoading = false;
        });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleSave() async {
    final currentUser = AuthStateService.instance.currentUser;
    if (currentUser == null) return;

    final newSaved = !_isSaved;
    setState(() => _isSaved = newSaved);

    try {
      final savedIds = List<String>.from(currentUser.savedConfessionIds);
      if (newSaved) {
        savedIds.add(widget.confession.id);
      } else {
        savedIds.remove(widget.confession.id);
      }
      final updatedUser = currentUser.copyWith(savedConfessionIds: savedIds);
      await AppwriteDbService.instance.updateSavedConfessions(
        currentUser.id,
        savedIds,
      );
      AuthStateService.instance.updateUser(updatedUser);
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

    final newComment = Comment(
      id: ID.unique(),
      confessionId: widget.confession.id,
      authorId: currentUser.id,
      content: text.isNotEmpty ? text : 'Shared a visual whisper... 🕯️',
      createdAt: DateTime.now(),
      imageUrl: _mockSelectedImagePath,
      isAuthor: widget.confession.authorId == currentUser.id,
    );

    setState(() {
      _comments.add(newComment);
      _commentController.clear();
      _mockSelectedImagePath = null;
    });
    FocusScope.of(context).unfocus();

    try {
      await AppwriteDbService.instance.createComment(newComment);
      await AppwriteDbService.instance.incrementCommentsCount(
        widget.confession.id,
        widget.confession.commentsCount,
      );
    } catch (_) {}
  }

  void _deleteComment(int index) {
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
  }

  void _simulatePickImage() {
    setState(() {
      _mockSelectedImagePath = 'journal_snapshot_0${_comments.length + 1}.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo attached to the confession room ❤️'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pm = PlaybackManager();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pureBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confession Room',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: _isSaved ? AppColors.accentRed : AppColors.pureBlack,
            ),
            onPressed: _toggleSave,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                                  DateFormat('MMM d, h:mm a').format(widget.confession.createdAt),
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
                              future: UserCacheService.instance.getUser(widget.confession.authorId),
                              builder: (context, snapshot) {
                                final author = snapshot.data;
                                final authorName = author?.displayName ?? 'Anonymous';
                                final initial = authorName.isNotEmpty ? authorName[0].toUpperCase() : 'C';

                                return Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(5.0),
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
                                      style: Theme.of(context).textTheme.bodyMedium
                                          ?.copyWith(fontSize: 12),
                                    ),
                                  ],
                                );
                              }
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
                                overlayColor: AppColors.pureBlack.withOpacity(
                                  0.1,
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
                                    if (isActive)
                                      pm.seek(
                                        (progress - 0.05).clamp(0.0, 1.0),
                                      );
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
                                    child: Icon(
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
                                    if (isActive)
                                      pm.seek(
                                        (progress + 0.05).clamp(0.0, 1.0),
                                      );
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

                  _comments.isEmpty
                      ? Container(
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
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            final showDelete =
                                comment.authorId == SampleData.currentUser.id ||
                                widget.confession.authorId == SampleData.currentUser.id;

                            return CommentBubble(
                              comment: comment,
                              onDelete: showDelete
                                  ? () => _deleteComment(index)
                                  : null,
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
                                Icons.image_outlined,
                                size: 14,
                                color: AppColors.pureBlack,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _mockSelectedImagePath!,
                                style: const TextStyle(
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
                        SampleData.currentUser.id) ...[
                      GestureDetector(
                        onTap: _simulatePickImage,
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
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
                      onTap: _addComment,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.pureBlack,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
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
                    : AppColors.textSecondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
