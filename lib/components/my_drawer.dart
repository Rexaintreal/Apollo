import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apollo/models/playlist_provider.dart';
import 'package:apollo/models/songs.dart';
import 'package:apollo/pages/settings_page.dart';
import 'package:url_launcher/url_launcher.dart'; 

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Home
              _drawerCard(
                context,
                icon: Icons.home,
                label: 'Home',
                onTap: () => Navigator.pop(context),
              ),

              // Import Songs
              _drawerCard(
                context,
                icon: Icons.library_music,
                label: 'Import Songs',
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['mp3', 'wav', 'm4a'],
                  );

                  if (result != null) {
                    final provider = Provider.of<PlaylistProvider>(
                      // ignore: use_build_context_synchronously
                      context,
                      listen: false,
                    );

                    for (final file in result.files) {
                      final path = file.path;
                      if (path == null) continue;

                      final cleanName = file.name
                          .replaceAll(RegExp(r'\.(mp3|wav|m4a)$', caseSensitive: false), '')
                          .replaceAll('_', ' ');

                      provider.addSong(
                        Song(
                          songName: cleanName,
                          artistName: 'Unknown Artist',
                          albumArtImagePath: '',
                          audioPath: path,
                        ),
                      );
                    }
                  }

                  if (context.mounted) Navigator.pop(context);
                },
              ),

              // Settings
              _drawerCard(
                context,
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),

              const Spacer(),

              // Feedback → redirect to website
              _drawerCard(
                context,
                icon: Icons.feedback_rounded, 
                label: 'Send Feedback',
                onTap: () async {
                  final url = Uri.parse("https://saurabhcodesawfully.pythonanywhere.com/");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open link')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Matches HomePage look: Card + ListTile with rounded corners
  Widget _drawerCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: colors.inversePrimary),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
      ),
    );
  }
}