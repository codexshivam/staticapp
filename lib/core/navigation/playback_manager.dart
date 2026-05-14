import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import '../../models/confession.dart';
import '../../services/database_service.dart';
import '../../services/subscription_service.dart';
import '../../services/auth_state_service.dart';

class PlaybackManager extends ChangeNotifier {
  static final PlaybackManager _instance = PlaybackManager._internal();
  factory PlaybackManager() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Confession> _history = [];

  Confession? _activeConfession;
  bool _isPlaying = false;
  bool _isBuffering = false;
  double _progress = 0.0;
  Duration _elapsed = Duration.zero;
  bool _hasIncrementedForCurrentConfession = false;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;

  PlaybackManager._internal() {
    _initAudioSession();
    _loadHistory();
    _setupAudioListeners();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> _loadHistory() async {
    try {
      final savedConfessions = await DatabaseService.instance.getHistoryConfessions();
      _history.clear();
      _history.addAll(savedConfessions);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load SQLite history: $e');
    }
  }

  void _setupAudioListeners() {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _elapsed = position;
      if (_audioPlayer.duration != null &&
          _audioPlayer.duration!.inMilliseconds > 0) {
        _progress =
            position.inMilliseconds / _audioPlayer.duration!.inMilliseconds;
      }
      if (!_hasIncrementedForCurrentConfession && position.inSeconds >= 10) {
        _hasIncrementedForCurrentConfession = true;
        SubscriptionService.instance.incrementDailyPlaybackCount();
      }
      notifyListeners();
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing && state.processingState != ProcessingState.completed;
      _isBuffering = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _progress = 0.0;
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
      notifyListeners();
    });
  }

  Confession? get activeConfession => _activeConfession;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  double get progress => _progress;
  Duration get elapsed => _elapsed;

  String get elapsedString {
    final minutes = _elapsed.inMinutes.toString();
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<Confession> get history => _history;

  void addToHistory(Confession confession) {
    final confWithListenTime = confession.copyWith(listenedAt: DateTime.now());
    _history.removeWhere((c) => c.id == confession.id);
    _history.insert(0, confWithListenTime);
    DatabaseService.instance.saveHistoryItem(confWithListenTime);
    notifyListeners();
  }

  void removeFromHistory(String id) {
    _history.removeWhere((c) => c.id == id);
    DatabaseService.instance.deleteHistoryItem(id);
    notifyListeners();
  }

  void removeMultipleFromHistory(Set<String> ids) {
    _history.removeWhere((c) => ids.contains(c.id));
    DatabaseService.instance.deleteMultipleHistoryItems(ids);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    DatabaseService.instance.clearAllHistory();
    notifyListeners();
  }

  Future<void> play(Confession confession, {BuildContext? context, bool reset = false}) async {
    try {
      final canPlay = await SubscriptionService.instance.canPlayConfession();
      if (!canPlay) {
        SubscriptionService.instance.showPaywall();
        return;
      }

      if (_activeConfession?.id != confession.id || reset) {
        final isDifferent = _activeConfession?.id != confession.id;
        _activeConfession = confession;
        _progress = 0.0;
        _elapsed = Duration.zero;
        _hasIncrementedForCurrentConfession = false;

        if (isDifferent) {
          _isBuffering = true;
          notifyListeners();

          final currentUser = AuthStateService.instance.currentUser;
          final artistName = currentUser != null
              ? '${currentUser.displayName} (${currentUser.handle})'
              : 'Confessions Journal';

          final mediaItem = MediaItem(
            id: confession.id,
            title: confession.title,
            artist: artistName,
            artUri: Uri.parse('asset:///assets/logo.png'),
          );

          if (confession.audioFilePath != null &&
              confession.audioFilePath!.isNotEmpty) {
            final source = AudioSource.uri(
              Uri.file(confession.audioFilePath!),
              tag: mediaItem,
            );
            await _audioPlayer.setAudioSource(source);
          } else if (confession.audioUrl != null &&
              confession.audioUrl!.isNotEmpty) {
            final source = AudioSource.uri(
              Uri.parse(confession.audioUrl!),
              tag: mediaItem,
            );
            await _audioPlayer.setAudioSource(source);
          } else {
            _isBuffering = false;
            debugPrint('No real audio source provided for this confession.');
          }
        } else {
          await _audioPlayer.seek(Duration.zero);
          notifyListeners();
        }
      }

      addToHistory(confession);
      if (confession.audioUrl != null || confession.audioFilePath != null) {
        _audioPlayer.play();
      } else {
        _isPlaying = true;
        Future.delayed(const Duration(seconds: 10), () {
          if (_isPlaying &&
              _activeConfession?.id == confession.id &&
              !_hasIncrementedForCurrentConfession) {
            _hasIncrementedForCurrentConfession = true;
            SubscriptionService.instance.incrementDailyPlaybackCount();
          }
        });
        notifyListeners();
      }
    } catch (e) {
      _isBuffering = false;
      notifyListeners();
      debugPrint('Error playing audio: $e');
    }
  }

  void pause() {
    _audioPlayer.pause();
    if (_activeConfession?.audioUrl == null &&
        _activeConfession?.audioFilePath == null) {
      _isPlaying = false;
      notifyListeners();
    }
  }

  void togglePlay(Confession confession, {BuildContext? context}) {
    if (_activeConfession?.id == confession.id && _isPlaying) {
      pause();
    } else {
      play(confession, context: context);
    }
  }

  void seek(double value) {
    final newPos = value.clamp(0.0, 1.0);
    final duration = _audioPlayer.duration;
    if (duration != null) {
      _audioPlayer.seek(
        Duration(milliseconds: (duration.inMilliseconds * newPos).round()),
      );
    }
    _progress = newPos;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
