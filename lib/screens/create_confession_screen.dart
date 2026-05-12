import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../mock_data/sample_data.dart';
import '../models/confession.dart';

enum RecordState { idle, recording, recorded, publishing, success }

class CreateConfessionScreen extends StatefulWidget {
  const CreateConfessionScreen({super.key});

  @override
  State<CreateConfessionScreen> createState() => _CreateConfessionScreenState();
}

class _CreateConfessionScreenState extends State<CreateConfessionScreen> {
  RecordState _state = RecordState.idle;
  final _titleController = TextEditingController();
  
  // Timer & levels state for recording
  Timer? _recordTimer;
  int _secondsRecorded = 0;
  List<double> _micLevels = List.filled(20, 0.1);

  // Publishing state steps
  String _publishingText = 'Formatting audio stream...';
  double _publishProgress = 0.0;

  @override
  void dispose() {
    _recordTimer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _state = RecordState.recording;
      _secondsRecorded = 0;
      _micLevels = List.filled(20, 0.15);
    });

    final random = Random();
    _recordTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        _secondsRecorded = (timer.tick * 0.15).floor();
        // Shift old mic levels and add a new random level
        _micLevels = List.generate(20, (index) {
          return 0.1 + random.nextDouble() * 0.8;
        });
      });
    });
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    _recordTimer = null;
    setState(() {
      _state = RecordState.recorded;
    });
  }

  void _resetRecording() {
    setState(() {
      _state = RecordState.idle;
      _secondsRecorded = 0;
      _micLevels = List.filled(20, 0.1);
    });
  }

  void _simulateUploadFile() {
    setState(() {
      _state = RecordState.recorded;
      _secondsRecorded = 145; // 2m 25s
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio file imported successfully ❤️'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _publishConfession() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your confession ❤️'),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (title.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title must be 50 characters or less ❤️'),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Begin progression pipeline
    setState(() {
      _state = RecordState.publishing;
      _publishProgress = 0.2;
      _publishingText = 'Processing recording... 🌧️';
    });

    // Step 1: Encrypt
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _publishProgress = 0.5;
          _publishingText = 'Securing account initials... 🔒';
        });
      }
    });

    // Step 2: Spreading
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _publishProgress = 0.8;
          _publishingText = 'Uploading confession... ✨';
        });
      }
    });

    // Step 3: Success
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Create actual confession object and prepend it to global list!
        final id = 'conf_user_${DateTime.now().millisecondsSinceEpoch}';
        final newConf = Confession(
          id: id,
          title: title,
          authorName: SampleData.currentUser.displayName,
          authorHandle: SampleData.currentUser.handle,
          authorId: SampleData.currentUser.id,
          timestamp: 'Just now',
          durationString: _formatDuration(_secondsRecorded),
          durationSeconds: _secondsRecorded == 0 ? 120 : _secondsRecorded,
          waveformData: SampleData.generateWaveform(35),
          likesCount: 0,
          commentsCount: 0,
          isSaved: false,
          dateText: '2026-05-12', // Today
        );

        SampleData.mockConfessions.insert(0, newConf); // Insert at the very top!

        setState(() {
          _publishProgress = 1.0;
          _state = RecordState.success;
        });

        // Auto close dialog modal after 1.5 seconds
        Timer(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.withOpacity(0.95),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top dismiss row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tell Your Story',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.cardBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: AppColors.pureBlack),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // CORE INTERACTIVE STATE BOX
              _buildCoreStateWidget(context),

              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoreStateWidget(BuildContext context) {
    switch (_state) {
      
      // 1. IDLE STATE
      case RecordState.idle:
        return Column(
          children: [
            Text(
              'Share your confession ❤️',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Share what's on your mind. Record a voice confession anonymously.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 48),

            // Record Button (Glowing Pulse effect container)
            GestureDetector(
              onTap: _startRecording,
              child: Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.pureBlack,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'TAP TO RECORD',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),

            const SizedBox(height: 40),
            const Text('— OR —', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            const SizedBox(height: 30),

            // Import button
            OutlinedButton.icon(
              onPressed: _simulateUploadFile,
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: const Text('CHOOSE AUDIO FILE'),
            ),
          ],
        );

      // 2. RECORDING STATE
      case RecordState.recording:
        return Column(
          children: [
            Text(
              _formatDuration(_secondsRecorded),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recording...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Animated Mic Waves levels
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _micLevels.map((level) {
                  return Container(
                    width: 4,
                    height: (level * 60).clamp(4.0, 60.0),
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    decoration: BoxDecoration(
                      color: AppColors.pureBlack,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 50),

            // Stop button
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.pureBlack,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'TAP TO STOP',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
          ],
        );

      // 3. RECORDED STATE (previewing / detailing)
      case RecordState.recorded:
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Voice Confession Recorded ❤️',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Duration: ${_formatDuration(_secondsRecorded)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Title input
              TextField(
                controller: _titleController,
                maxLength: 50,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Title your confession...',
                  hintText: 'e.g. A message to my first love...',
                  counterStyle: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetRecording,
                      child: const Text('RE-RECORD'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _publishConfession,
                      child: const Text('POST'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );

      // 4. PUBLISHING PROGRESS PIPELINE
      case RecordState.publishing:
        return Column(
          children: [
            const CircularProgressIndicator(
              color: AppColors.pureBlack,
              strokeWidth: 3.0,
            ),
            const SizedBox(height: 28),
            Text(
              _publishingText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2.5),
              child: SizedBox(
                height: 5,
                width: 200,
                child: LinearProgressIndicator(
                  value: _publishProgress,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pureBlack),
                ),
              ),
            ),
          ],
        );

      // 5. SUCCESS FINALE STATE
      case RecordState.success:
        return Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.accentRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Published ❤️',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your voice confession is now live anonymously.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
    }
  }
}
