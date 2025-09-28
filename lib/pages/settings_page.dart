import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:apollo/themes/theme_provider.dart';
import 'package:apollo/themes/cat_provider.dart';
import 'package:apollo/models/miniplayer_provider.dart';
import 'package:apollo/components/mini_player.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final catProvider = Provider.of<CatProvider>(context);
    final miniPlayerProvider = Provider.of<MiniPlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("S E T T I N G S"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Dark Mode toggle
                Container(
                  decoration: BoxDecoration(
                    // Using standard Container with static color
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: const Icon(Icons.brightness_6),
                    title: Text(
                      "Dark Mode",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Mini Player toggle
                Container(
                  decoration: BoxDecoration(
                    // Using standard Container with static color
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: const Icon(Icons.library_music),
                    title: Text(
                      "Mini Player",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    subtitle: Text(
                      "Show player controls on home page",
                      style: TextStyle(
                        fontSize: 12,
                        // ignore: deprecated_member_use
                        color: Theme.of(context)
                            .colorScheme
                            .inversePrimary
                            .withOpacity(0.7),
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      value: miniPlayerProvider.isMiniPlayerEnabled,
                      onChanged: (value) =>
                          miniPlayerProvider.toggleMiniPlayer(value),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dancing Cat toggle
                Container(
                  decoration: BoxDecoration(
                    // Using standard Container with static color
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: Image.asset(
                      "assets/cat.png",
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    title: Text(
                      "Dancing Cat",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      value: catProvider.isCatEnabled,
                      onChanged: (value) => catProvider.toggleCat(value),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Check more apps by Saurabh (inline)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: const Icon(Icons.link),
                    title: const Text(
                      "By Saurabh Tiwari",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final url = Uri.parse(
                          "https://saurabhcodesawfully.pythonanywhere.com/");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ),

                const SizedBox(height: 40), // spacing before version

                // App version text at bottom
                Center(
                  child: Text(
                    "apollo v2.0",
                    style: TextStyle(
                      fontSize: 14,
                      // ignore: deprecated_member_use
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mini Player at the bottom
          const MiniPlayer(),
        ],
      ),
    );
  }
}