import 'package:flutter/material.dart';
import 'package:apollo/components/album_art.dart';
import 'package:apollo/components/my_drawer.dart';
import 'package:apollo/models/playlist_provider.dart';
import 'package:apollo/models/songs.dart';
import 'package:apollo/pages/song_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final dynamic playlistProvider;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  // go to a song
  void goToSong(int songIndex) {
    playlistProvider.currentSongIndex = songIndex;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SongPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("S O N G S"),
      ),
      drawer: MyDrawer(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<Song> playlist = value.playlist;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              final Song song = playlist[index];

              // check if song is imported (file path)
              final bool isImported = song.audioPath.startsWith('/') ||
                  song.audioPath.startsWith('file://');

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => goToSong(index),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AlbumArt(song: song, size: 55),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.songName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artistName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isImported)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 22),
                            // ignore: deprecated_member_use
                            color: Colors.redAccent.withOpacity(0.85),
                            onPressed: () {
                              value.removeSong(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor:
                                      // ignore: deprecated_member_use
                                      colors.surface.withOpacity(0.95),
                                  content: Text(
                                    "${song.songName} deleted",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.inversePrimary,
                                    ),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
