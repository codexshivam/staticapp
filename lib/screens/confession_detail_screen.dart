import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/playback_manager.dart';
import '../models/confession.dart';
import '../models/comment.dart';
import '../mock_data/sample_data.dart';
import '../widgets/comment_bubble.dart';

class ConfessionDetailScreen extends StatefulWidget {
  final Confession confession;

  const ConfessionDetailScreen({
    super.key,
    required this.confession,
  });

  @override
  State<ConfessionDetailScreen> createState() => _ConfessionDetailScreenState();
}

class _ConfessionDetailScreenState extends State<ConfessionDetailScreen> {
  final _commentController = TextEditingController();
  late List<Comment> _comments;
  bool _isSaved = false;
  String? _mockSelectedImagePath; // Simulated attached photo state

  @override
  void initState() {
    super.initState();
    _comments = List.from(SampleData.mockComments[widget.confession.id] ?? []);
    _isSaved = widget.confession.isSaved;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Confession saved to your private journal ❤️' : 'Confession unsaved'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty && _mockSelectedImagePath == null) return;

    final newComment = Comment(
      id: 'comm_user_${DateTime.now().millisecondsSinceEpoch}',
      authorName: SampleData.currentUser.displayName,
      authorAvatar: SampleData.currentUser.initials,
      content: text.isNotEmpty ? text : 'Shared a visual whisper... 🕯️',
      timestamp: 'Just now',
      imageUrl: _mockSelectedImagePath,
      isAuthor: widget.confession.authorId == SampleData.currentUser.id,
    );

    setState(() {
      _comments.add(newComment);
      _commentController.clear();
      _mockSelectedImagePath = null; // Reset image attachments
    });

    FocusScope.of(context).unfocus();
  }

  void _deleteComment(int index) {
    setState(() {
      _comments.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Whisper deleted from the room ❤️'),
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

  void _triggerUpiTip(int amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Support Author ❤️',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        content: Text(
          'Sending a quiet gift of ₹$amount to ${widget.confession.authorName} at ${widget.confession.authorHandle}.\n\nThis will open your primary UPI app.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('₹$amount UPI support sent to ${widget.confession.authorName}! ❤️'),
                  backgroundColor: AppColors.pureBlack,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Proceed'),
          )
        ],
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
          // Expanded scrolling content (Player + UPI Support + Comment Lists)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // 1. HERO AUDIO PLAYER CARD
                  ListenableBuilder(
                    listenable: pm,
                    builder: (context, _) {
                      final isActive = pm.activeConfession?.id == widget.confession.id;
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
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Poetic category / Tag
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.confession.tags.isNotEmpty 
                                      ? '#${widget.confession.tags[0].toLowerCase()}' 
                                      : '#whisper',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accentRed,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  widget.confession.timestamp,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Confession Title
                            Text(
                              widget.confession.title,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.pureBlack,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Author section
                            Row(
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
                                    widget.confession.authorName.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'by ${widget.confession.authorName} • ${widget.confession.authorHandle}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Main audio slider progress or large waveform
                            _buildLargeWaveform(widget.confession.waveformData, progress),
                            const SizedBox(height: 14),

                            // Timeline & Slider track
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                activeTrackColor: AppColors.pureBlack,
                                inactiveTrackColor: AppColors.divider,
                                thumbColor: AppColors.pureBlack,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                                overlayColor: AppColors.pureBlack.withOpacity(0.1),
                              ),
                              child: Slider(
                                value: progress,
                                onChanged: (val) {
                                  if (isActive) {
                                    pm.seek(val);
                                  } else {
                                    pm.play(widget.confession);
                                    pm.seek(val);
                                  }
                                },
                              ),
                            ),

                            // Elapsed Duration Details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isActive ? pm.elapsedString : '0:00',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.confession.durationString,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Audio Playback Controls Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10, size: 28),
                                  onPressed: () {
                                    if (isActive) pm.seek((progress - 0.05).clamp(0.0, 1.0));
                                  },
                                ),
                                const SizedBox(width: 14),
                                GestureDetector(
                                  onTap: () => pm.togglePlay(widget.confession),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.pureBlack,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Icon(
                                      isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: AppColors.cardBg,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                IconButton(
                                  icon: const Icon(Icons.forward_10, size: 28),
                                  onPressed: () {
                                    if (isActive) pm.seek((progress + 0.05).clamp(0.0, 1.0));
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // 2. UPI SUPPORT BOX: "Support the author ❤️"
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Support the author ❤️',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'If this voice note touched you, buy them a hot tea or support their storytelling anonymously.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _buildTipButton('₹20', 20),
                            const SizedBox(width: 8),
                            _buildTipButton('₹50', 50),
                            const SizedBox(width: 8),
                            _buildTipButton('₹100', 100),
                            const SizedBox(width: 8),
                            _buildTipButton('₹200', 200),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. CONFESSION ROOM ❤️ CHAT BOARD HEADER
                  Row(
                    children: [
                      Text(
                        'Confession Room ❤️',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.pureBlack,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${_comments.length} whispers',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Comments listing
                  _comments.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: Text(
                            'no letters written here yet. be the first to leave a whisper ❤️',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                            final showDelete = comment.authorName == SampleData.currentUser.displayName || 
                                              widget.confession.authorId == SampleData.currentUser.id;

                            return CommentBubble(
                              comment: comment,
                              onDelete: showDelete ? () => _deleteComment(index) : null,
                            );
                          },
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 4. PERSISTENT INTIMATE COMMENT INPUT BAR (at the bottom)
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              border: const Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image preview row (if image is chosen)
                if (_mockSelectedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.image_outlined, size: 14, color: AppColors.pureBlack),
                              const SizedBox(width: 6),
                              Text(
                                _mockSelectedImagePath!,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() => _mockSelectedImagePath = null),
                                child: const Icon(Icons.close, size: 14, color: AppColors.accentRed),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // TextField Row
                Row(
                  children: [
                    // Mock Image attach icon button
                    GestureDetector(
                      onTap: _simulatePickImage,
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Input Text
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        cursorColor: AppColors.pureBlack,
                        style: const TextStyle(fontSize: 13.5),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Leave a silent whisper inside...',
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    // Send Button (Raised Square with 5px radius)
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
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Tipping custom buttons
  Widget _buildTipButton(String label, int amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _triggerUpiTip(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.pureBlack,
            ),
          ),
        ),
      ),
    );
  }

  // Large Waveform Drawing
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
