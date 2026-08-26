import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'custom_theme_editor.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Theme'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildThemeTile(
            context: context,
            title: 'System Default',
            theme: AppTheme.system,
            currentTheme: themeProvider.currentTheme,
            onTap: () => themeProvider.setTheme(AppTheme.system),
          ),
          _buildThemeTile(
            context: context,
            title: 'Cyberpunk',
            theme: AppTheme.cyberpunk,
            currentTheme: themeProvider.currentTheme,
            onTap: () => themeProvider.setTheme(AppTheme.cyberpunk),
          ),
          _buildThemeTile(
            context: context,
            title: 'Retro Terminal',
            theme: AppTheme.retro,
            currentTheme: themeProvider.currentTheme,
            onTap: () => themeProvider.setTheme(AppTheme.retro),
          ),
          _buildThemeTile(
            context: context,
            title: 'Nothing (Dark)',
            theme: AppTheme.nothing,
            currentTheme: themeProvider.currentTheme,
            onTap: () => themeProvider.setTheme(AppTheme.nothing),
          ),
          _buildThemeTile(
            context: context,
            title: 'Nothing (Light)',
            theme: AppTheme.nothingLight,
            currentTheme: themeProvider.currentTheme,
            onTap: () => themeProvider.setTheme(AppTheme.nothingLight),
          ),
          _buildThemeTile(
            context: context,
            title: 'Custom Theme',
            theme: AppTheme.custom,
            currentTheme: themeProvider.currentTheme,
            onTap: () => themeProvider.setTheme(AppTheme.custom),
            trailingWidget: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomThemeEditorScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required String title,
    required AppTheme theme,
    required AppTheme currentTheme,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    final isSelected = theme == currentTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingWidget != null) trailingWidget,
          if (trailingWidget != null) const SizedBox(width: 8),
          isSelected
              ? Icon(Icons.check_circle, color: colorScheme.primary)
              : const Icon(Icons.circle_outlined, color: Colors.grey),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
