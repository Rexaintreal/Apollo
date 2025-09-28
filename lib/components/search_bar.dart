import 'package:flutter/material.dart';

class SongSearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const SongSearchBar({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: onChanged,
        cursorColor: colors.primary,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search songs...',
          filled: true,
          fillColor: colors.surfaceContainerHighest.withOpacity(0.2),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: colors.outline.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: colors.primary),
          ),
        ),
      ),
    );
  }
}
