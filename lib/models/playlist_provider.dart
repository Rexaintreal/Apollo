import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';   
import 'songs.dart';

class PlaylistProvider extends ChangeNotifier {
  static const _playlistKey = 'playlist_v1';
  static const _currentIndexKey = 'current_index_v1';
  static const _shuffleKey = 'shuffle_v1';
  static const _repeatKey = 'repeat_v1';

  final List<Song> _playlist = [
    Song(
      songName: "Blinding Lights",
      artistName: "The Weekend",
      albumArtImagePath: "assets/images/Blinding_Lights.jpg",
      audioPath: "audio/Blinding_Lights.mp3",
    )
  ];

  int? _currentSongIndex;
  bool _isShuffleMode = false;
  bool _isRepeatMode = false;
  final List<int> _shuffleHistory = [];
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool isPlaying = false;

  PlaylistProvider() {
    listenToDuration();
    _loadFromDisk();
  }

  // =======================
  // PERSISTENCE
  // =======================
  Future<void> _savePlaylistToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonSongs = _playlist.map((s) => s.toJson()).toList();
    await prefs.setString(_playlistKey, jsonEncode(jsonSongs));
  }

  Future<void> _saveStateToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentIndexKey, _currentSongIndex ?? -1);
    await prefs.setBool(_shuffleKey, _isShuffleMode);
    await prefs.setBool(_repeatKey, _isRepeatMode);
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistKey);
    if (raw != null && raw.isNotEmpty) {
      final List decoded = jsonDecode(raw) as List;
      final loaded = decoded
          .whereType<Map<String, dynamic>>()
          .map((m) => Song.fromJson(m))
          .toList();
      _playlist
        ..clear()
        ..addAll(loaded);
    } else {
      await _savePlaylistToDisk();
    }

    final idx = prefs.getInt(_currentIndexKey) ?? -1;
    _currentSongIndex = (idx >= 0 && idx < _playlist.length) ? idx : null;
    _isShuffleMode = prefs.getBool(_shuffleKey) ?? false;
    _isRepeatMode = prefs.getBool(_repeatKey) ?? false;
    notifyListeners();
  }

  // =======================
  // PLAYLIST API
  // =======================
  /// Copy a temp file (from FilePicker) to a permanent location
  Future<String> _persistPickedFile(String tempPath, String fileName) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final savedPath = '${appDocDir.path}/$fileName';
    final savedFile = await File(tempPath).copy(savedPath);
    return savedFile.path;
  }

  /// Add a song; if [isTempFile] is true, copy to permanent folder first
  Future<void> addSong(Song song, {bool isTempFile = false}) async {
    String finalPath = song.audioPath;
    if (isTempFile) {
      // Extract just the filename if available
      final name = song.audioPath.split('/').last;
      finalPath = await _persistPickedFile(song.audioPath, name);
    }

    _playlist.add(
      Song(
        songName: song.songName,
        artistName: song.artistName,
        albumArtImagePath: song.albumArtImagePath,
        audioPath: finalPath,
      ),
    );

    notifyListeners();
    await _savePlaylistToDisk();
  }

  Future<void> removeSong(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    // delete imported file if it exists
    final song = _playlist[index];
    if (song.audioPath.startsWith('/')) {
      final file = File(song.audioPath);
      if (await file.exists()) await file.delete();
    }

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

  // =======================
  // PLAYER API
  // =======================
  void play() async {
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop();

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
      return (_currentSongIndex! < _playlist.length - 1)
          ? _currentSongIndex! + 1
          : 0;
    }
  }

  int _getPreviousSongIndex() {
    if (_isShuffleMode && _shuffleHistory.isNotEmpty) {
      return _shuffleHistory.removeLast();
    } else {
      return (_currentSongIndex! > 0)
          ? _currentSongIndex! - 1
          : _playlist.length - 1;
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

  void playPreviousSong() {
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      currentSongIndex = _getPreviousSongIndex();
    }
  }

  void toggleShuffle() {
    _isShuffleMode = !_isShuffleMode;
    if (!_isShuffleMode) _shuffleHistory.clear();
    notifyListeners();
    _saveStateToDisk();
  }

  void toggleRepeat() {
    _isRepeatMode = !_isRepeatMode;
    notifyListeners();
    _saveStateToDisk();
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((d) {
      _totalDuration = d;
      notifyListeners();
    });
    _audioPlayer.onPositionChanged.listen((p) {
      _currentDuration = p;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((_) {
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

  // =======================
  // GETTERS & SETTERS
  // =======================
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlayingStatus => isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isShuffleMode => _isShuffleMode;
  bool get isRepeatMode => _isRepeatMode;

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) play();
    notifyListeners();
    _saveStateToDisk();
  }
}
