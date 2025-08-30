import 'package:flutter/material.dart';
import 'package:apollo/components/album_art.dart';
import 'package:apollo/components/neu_box.dart';
import 'package:apollo/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  // State variables for additional functionalities
  bool isShuffleOn = false;
  bool isRepeatOn = false;
  bool isFavorite = false;

  // convert duration into minutes and seconds
  String formatTime(Duration duration) {
    String twoDigitSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String formattedTime = "${duration.inMinutes}:$twoDigitSeconds";
    return formattedTime;
  }

  // Show options menu
  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Song Info'),
              onTap: () {
                Navigator.pop(context);
                _showSongInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show song information dialog
  void _showSongInfo() {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    final currentSong = playlistProvider.playlist[playlistProvider.currentSongIndex ?? 0];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Song Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Song: ${currentSong.songName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Artist: ${currentSong.artistName}'),
            const SizedBox(height: 8),
            Text('Duration: ${formatTime(playlistProvider.totalDuration)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Toggle shuffle mode
  void _toggleShuffle() {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.toggleShuffle();
    setState(() {
      isShuffleOn = playlistProvider.isShuffleMode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isShuffleOn ? 'Shuffle enabled' : 'Shuffle disabled'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Toggle repeat mode
  void _toggleRepeat() {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.toggleRepeat();
    setState(() {
      isRepeatOn = playlistProvider.isRepeatMode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRepeatOn ? 'Repeat enabled' : 'Repeat disabled'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        // get playlist 
        final playlist = value.playlist;

        // get current song index
        final currentSong = playlist[value.currentSongIndex ?? 0];

        // return scaffold UI 
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
          child: Column(
            children: [
              // 🔹 Top Navbar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(
                        currentSong.songName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: _showOptionsMenu,
                      icon: const Icon(Icons.menu),
                    ),
                  ],
                ),
              ),

              // 🔹 Centered main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // album artwork
                      AlbumArt(
                        song: currentSong,
                        size: MediaQuery.of(context).size.width * 0.8, // make it big
                      ),

                      const SizedBox(height: 20),

                      // Song + artist
                      Text(
                        currentSong.songName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentSong.artistName,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 30),

                      // song duration + progress bar
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatTime(value.currentDuration)),
                                GestureDetector(
                                  onTap: _toggleShuffle,
                                  child: Icon(
                                    Icons.shuffle,
                                    color: value.isShuffleMode ? Colors.green : null,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _toggleRepeat,
                                  child: Icon(
                                    Icons.repeat,
                                    color: value.isRepeatMode ? Colors.green : null,
                                  ),
                                ),
                                Text(formatTime(value.totalDuration)),
                              ],
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              min: 0,
                              max: value.totalDuration.inSeconds.toDouble() > 0
                                  ? value.totalDuration.inSeconds.toDouble()
                                  : 1,
                              value: value.currentDuration.inSeconds.toDouble().clamp(
                                0,
                                value.totalDuration.inSeconds.toDouble() > 0
                                    ? value.totalDuration.inSeconds.toDouble()
                                    : 1,
                              ),
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey[400],
                              onChanged: (double newValue) {},
                              onChangeEnd: (double newValue) {
                                value.seek(Duration(seconds: newValue.toInt()));
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // playback controls
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: value.playPreviousSong,
                              child: const NeuBox(
                                child: Icon(Icons.skip_previous, size: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: value.pauseOrResume,
                              child: NeuBox(
                                child: Icon(
                                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: value.playNextSong,
                              child: const NeuBox(
                                child: Icon(Icons.skip_next, size: 32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        );  
      }
    );
  }
}