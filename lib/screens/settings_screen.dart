import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 24),
          Text(
            'About',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Ultimate Calculator'),
            subtitle: const Text('Version 1.0.0'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  }) {
    final isSelected = theme == currentTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
