import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apollo/models/songs.dart';

class PlaylistProvider extends ChangeNotifier {
  // =========================
  // P E R S I S T E N C E
  // =========================
  static const _playlistKey = 'playlist_v1';
  static const _currentIndexKey = 'current_index_v1';     
  static const _shuffleKey = 'shuffle_v1';                
  static const _repeatKey = 'repeat_v1';                  

  // playlist of songs (defaults initially)
  final List<Song> _playlist = [
    Song(
      songName: "Blinding Lights",
      artistName: "The Weekend",
      albumArtImagePath: "assets/images/Blinding_Lights.jpg",
      audioPath: "audio/Blinding_Lights.mp3",
    )
  ];


  // current song index
  int? _currentSongIndex;

  // shuffle and repeat modes
  bool _isShuffleMode = false;
  bool _isRepeatMode = false;

  // shuffle history to avoid immediate repeats
  final List<int> _shuffleHistory = [];
  final Random _random = Random();

  // audio player 
  final AudioPlayer _audioPlayer = AudioPlayer();

  // durations 
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // initially not playing
  bool isPlaying = false;

  // constructor
  PlaylistProvider() {
    listenToDuration();
    _loadFromDisk(); // <-- load saved state/playlist (replaces defaults if present)
  }

  // =========================
  // P E R S I S T : core
  // =========================
  Future<void> _savePlaylistToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonSongs = _playlist.map((s) => s.toJson()).toList();
      await prefs.setString(_playlistKey, jsonEncode(jsonSongs));
    } catch (_) {
      // swallow errors; you can log if needed
    }
  }

  Future<void> _saveStateToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentIndexKey, _currentSongIndex ?? -1);
      await prefs.setBool(_shuffleKey, _isShuffleMode);
      await prefs.setBool(_repeatKey, _isRepeatMode);
    } catch (_) {}
  }

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load playlist
      final raw = prefs.getString(_playlistKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw) as List;
        final loaded = decoded
            .whereType<Map<String, dynamic>>()
            .map((m) => Song.fromJson(m))
            .toList();

        // Replace defaults with saved
        _playlist
          ..clear()
          ..addAll(loaded);
      } else {
        // First run after adding persistence: persist existing defaults
        await _savePlaylistToDisk();
      }

      // Load optional state
      final idx = prefs.getInt(_currentIndexKey) ?? -1;
      _currentSongIndex = (idx >= 0 && idx < _playlist.length) ? idx : null;
      _isShuffleMode = prefs.getBool(_shuffleKey) ?? false;
      _isRepeatMode = prefs.getBool(_repeatKey) ?? false;

      notifyListeners();
    } catch (_) {
      // If anything goes wrong, keep defaults
      notifyListeners();
    }
  }

  // Optional helper if you ever want a "Reset to defaults" button:
  Future<void> resetToDefaults() async {
    // (Re)build your defaults here if needed; we already have them in file.
    await _savePlaylistToDisk();
    await _saveStateToDisk();
    notifyListeners();
  }

  // =========================
  // P L A Y L I S T  A P I
  // =========================
  Future<void> addSong(Song song) async {
    _playlist.add(song);
    notifyListeners();
    await _savePlaylistToDisk();
  }

  Future<void> removeSong(int index) async {
    if (index >= 0 && index < _playlist.length) {
      if (_currentSongIndex == index) {
        await _audioPlayer.stop();
        _currentSongIndex = null;
        isPlaying = false;
      } else if (_currentSongIndex != null && _currentSongIndex! > index) {
        _currentSongIndex = _currentSongIndex! - 1;
      }

      _playlist.removeAt(index);
      notifyListeners();
      await _savePlaylistToDisk();
      await _saveStateToDisk();
    }
  }

  // =========================
  // P L A Y E R  A P I
  // =========================
  void play() async {
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop(); // stop current song

    // file path vs asset path
    if (path.startsWith('/') || path.startsWith('file://')) {
      await _audioPlayer.play(DeviceFileSource(path));
    } else {
      await _audioPlayer.play(AssetSource(path));
    }

    isPlaying = true;
    notifyListeners();
  }

  void pause() async {
    await _audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await _audioPlayer.resume();
    isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() async {
    if (isPlaying) {
      pause();
    } else {
      resume();
    }
    notifyListeners();
  }

  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  int _getNextSongIndex() {
    if (_isShuffleMode) {
      if (_playlist.length <= 1) return 0;
      int nextIndex;
      int attempts = 0;
      do {
        nextIndex = _random.nextInt(_playlist.length);
        attempts++;
      } while (nextIndex == _currentSongIndex && attempts < 10);

      _shuffleHistory.add(nextIndex);
      if (_shuffleHistory.length > _playlist.length ~/ 2) {
        _shuffleHistory.removeAt(0);
      }

      return nextIndex;
    } else {
      if (_currentSongIndex! < _playlist.length - 1) {
        return _currentSongIndex! + 1;
      } else {
        return 0;
      }
    }
  }

  int _getPreviousSongIndex() {
    if (_isShuffleMode && _shuffleHistory.isNotEmpty) {
      int previousIndex = _shuffleHistory.removeLast();
      return previousIndex;
    } else {
      if (_currentSongIndex! > 0) {
        return _currentSongIndex! - 1;
      } else {
        return _playlist.length - 1;
      }
    }
  }

  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_isRepeatMode) {
        seek(Duration.zero);
        play();
      } else {
        currentSongIndex = _getNextSongIndex();
      }
    }
  }

  void playPreviousSong() async {
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      currentSongIndex = _getPreviousSongIndex();
    }
  }

  void toggleShuffle() {
    _isShuffleMode = !_isShuffleMode;
    if (!_isShuffleMode) {
      _shuffleHistory.clear();
    }
    notifyListeners();
    _saveStateToDisk(); 
  }

  void toggleRepeat() {
    _isRepeatMode = !_isRepeatMode;
    notifyListeners();
    _saveStateToDisk(); 
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeatMode) {
        seek(Duration.zero);
        play();
      } else {
        playNextSong();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // =========================
  // G E T T E R S
  // =========================
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlayingStatus => isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isShuffleMode => _isShuffleMode;
  bool get isRepeatMode => _isRepeatMode;

  // =========================
  // S E T T E R S
  // =========================
  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;

    if (newIndex != null) {
      play();
    }
    notifyListeners();
    _saveStateToDisk(); 
  }
}
