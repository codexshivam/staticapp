import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../models/confession.dart';
import '../../mock_data/sample_data.dart';
import '../../services/database_service.dart';

class PlaybackManager extends ChangeNotifier {
  static final PlaybackManager _instance = PlaybackManager._internal();
  factory PlaybackManager() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Confession> _history = [];

  Confession? _activeConfession;
  bool _isPlaying = false;
  double _progress = 0.0;
  Duration _elapsed = Duration.zero;

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
      final historyIds = await DatabaseService.instance.getHistoryIds();
      _history.clear();
      for (final id in historyIds) {
        final confession = SampleData.mockConfessions
            .cast<Confession?>()
            .firstWhere((c) => c?.id == id, orElse: () => null);
        if (confession != null) {
          _history.add(confession);
        }
      }
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
      notifyListeners();
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
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
  double get progress => _progress;
  Duration get elapsed => _elapsed;

  String get elapsedString {
    final minutes = _elapsed.inMinutes.toString();
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<Confession> get history => _history;

  void addToHistory(Confession confession) {
    _history.removeWhere((c) => c.id == confession.id);
    _history.insert(0, confession);
    DatabaseService.instance.saveHistoryItem(confession.id);
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

  Future<void> play(Confession confession) async {
    try {
      if (_activeConfession?.id != confession.id) {
        _activeConfession = confession;
        _progress = 0.0;
        _elapsed = Duration.zero;
        notifyListeners();

        if (confession.audioFilePath != null &&
            confession.audioFilePath!.isNotEmpty) {
          await _audioPlayer.setFilePath(confession.audioFilePath!);
        } else if (confession.audioUrl != null &&
            confession.audioUrl!.isNotEmpty) {
          await _audioPlayer.setUrl(confession.audioUrl!);
        } else {
          debugPrint('No real audio source provided for this confession.');
        }
      }

      addToHistory(confession);
      if (confession.audioUrl != null || confession.audioFilePath != null) {
        _audioPlayer.play();
      } else {
        _isPlaying = true;
        notifyListeners();
      }
    } catch (e) {
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

  void togglePlay(Confession confession) {
    if (_activeConfession?.id == confession.id && _isPlaying) {
      pause();
    } else {
      play(confession);
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
