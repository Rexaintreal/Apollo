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
                _buildSwitchTile(
                  context,
                  icon: Icons.brightness_6,
                  title: "Dark Mode",
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
                const SizedBox(height: 16),

                // Mini Player toggle
                _buildSwitchTile(
                  context,
                  icon: Icons.library_music,
                  title: "Mini Player",
                  subtitle: "Show player controls on home page",
                  value: miniPlayerProvider.isMiniPlayerEnabled,
                  onChanged: (value) =>
                      miniPlayerProvider.toggleMiniPlayer(value),
                ),
                const SizedBox(height: 16),

                // Dancing Cat toggle
                _buildSwitchTile(
                  context,
                  leading: Image.asset(
                    catProvider.selectedCat,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.pets),
                  ),
                  title: "Dancing Cat",
                  value: catProvider.isCatEnabled,
                  onChanged: (value) => catProvider.toggleCat(value),
                ),
                const SizedBox(height: 16),

                // Cat Selection Dropdown
                _buildCatDropdown(context, catProvider),
                const SizedBox(height: 16),

                // Cat Size Slider
                _buildCatSizeSlider(context, catProvider),
                const SizedBox(height: 16),

                // Cat Opacity Slider (NEW)
                _buildCatOpacitySlider(context, catProvider),
                const SizedBox(height: 16),

                // Cat Motion toggle
                _buildSwitchTile(
                  context,
                  icon: Icons.directions_run,
                  title: "Cat Motion",
                  subtitle: "Enable bouncing motion or drag manually",
                  value: catProvider.isMotionEnabled,
                  onChanged: (value) => catProvider.toggleMotion(value),
                ),
                const SizedBox(height: 16),

                // Check more apps
                _buildLinkTile(),
                const SizedBox(height: 40),

                // Version info
                Center(
                  child: Text(
                    "apollo v2.5",
                    style: TextStyle(
                      fontSize: 14,
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
          const MiniPlayer(),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    Widget? leading,
    IconData? icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: leading ?? Icon(icon),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withOpacity(0.7),
                ),
              )
            : null,
        trailing: CupertinoSwitch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildCatDropdown(BuildContext context, CatProvider catProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.pets),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Choose Cat",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: catProvider.selectedCat,
              icon: const Icon(Icons.arrow_drop_down),
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              selectedItemBuilder: (context) {
                return CatProvider.availableCats.map((String catPath) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset(catPath, fit: BoxFit.contain),
                  );
                }).toList();
              },
              items: CatProvider.availableCats.map((String catPath) {
                return DropdownMenuItem<String>(
                  value: catPath,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset(catPath, fit: BoxFit.contain),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) catProvider.selectCat(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatSizeSlider(BuildContext context, CatProvider catProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.height),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Cat Size",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              Text("${catProvider.catSize.toInt()}px",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )),
            ],
          ),
          SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.inversePrimary,
            inactiveTrackColor:
                Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
            thumbColor: Theme.of(context).colorScheme.inversePrimary,
            overlayColor:
                Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2),
            valueIndicatorColor: Theme.of(context).colorScheme.surface,
            valueIndicatorTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          child: Slider(
            value: catProvider.catSize,
            min: 50,
            max: 200,
            divisions: 15,
            label: "${catProvider.catSize.toInt()} px",
            onChanged: (value) => catProvider.setCatSize(value),
          ),
        ),

        ],
      ),
    );
  }

  Widget _buildCatOpacitySlider(BuildContext context, CatProvider catProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.opacity),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Cat Opacity",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              Text(
                "${(catProvider.catOpacity * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.inversePrimary,
              inactiveTrackColor:
                  Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
              thumbColor: Theme.of(context).colorScheme.inversePrimary,
              overlayColor:
                  Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2),
              valueIndicatorColor: Theme.of(context).colorScheme.surface,
              valueIndicatorTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            child: Slider(
              value: catProvider.catOpacity,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: "${(catProvider.catOpacity * 100).toInt()}%",
              onChanged: (value) => catProvider.setCatOpacity(value),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildLinkTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: const Icon(Icons.link),
        title: const Text(
          "By Saurabh Tiwari",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final url =
              Uri.parse("https://saurabhcodesawfully.pythonanywhere.com/");
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
