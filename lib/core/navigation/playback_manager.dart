import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/confession.dart';
import '../../mock_data/sample_data.dart';

class PlaybackManager extends ChangeNotifier {
  // Singleton Pattern
  static final PlaybackManager _instance = PlaybackManager._internal();
  factory PlaybackManager() => _instance;

  final List<Confession> _history = [];

  PlaybackManager._internal() {
    // Pre-populate with mock confessions to demonstrate history features
    _history.addAll(SampleData.mockConfessions);
  }

  Confession? _activeConfession;
  bool _isPlaying = false;
  double _progress = 0.0; // 0.0 to 1.0
  Timer? _timer;

  Confession? get activeConfession => _activeConfession;
  bool get isPlaying => _isPlaying;
  double get progress => _progress;

  Duration get elapsed {
    if (_activeConfession == null) return Duration.zero;
    final totalSeconds = _activeConfession!.durationSeconds;
    final elapsedSeconds = (totalSeconds * _progress).round();
    return Duration(seconds: elapsedSeconds);
  }

  String get elapsedString {
    final dur = elapsed;
    final minutes = dur.inMinutes.toString();
    final seconds = (dur.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<Confession> get history => _history;

  void addToHistory(Confession confession) {
    _history.removeWhere((c) => c.id == confession.id);
    _history.insert(0, confession);
    notifyListeners();
  }

  void removeFromHistory(String id) {
    _history.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void removeMultipleFromHistory(Set<String> ids) {
    _history.removeWhere((c) => ids.contains(c.id));
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void play(Confession confession) {
    if (_activeConfession?.id != confession.id) {
      _activeConfession = confession;
      _progress = 0.0;
    }
    _isPlaying = true;
    _startTimer();
    addToHistory(confession);
  }

  void pause() {
    _isPlaying = false;
    _stopTimer();
    notifyListeners();
  }

  void togglePlay(Confession confession) {
    if (_activeConfession?.id == confession.id && _isPlaying) {
      pause();
    } else {
      play(confession);
    }
  }

  void seek(double value) {
    _progress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_activeConfession == null) {
        _stopTimer();
        return;
      }

      final double step = 0.1 / _activeConfession!.durationSeconds;
      _progress += step;

      if (_progress >= 1.0) {
        _progress = 0.0;
        _isPlaying = false;
        _stopTimer();
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
