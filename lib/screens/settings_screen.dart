import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'theme_screen.dart';
import 'developer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          _buildSettingsGroup(
            context,
            children: [
              _buildSettingsTile(
                context: context,
                assetPath: 'assets/icons/theme.png',
                title: 'Theme',
                subtitle: _getThemeName(themeProvider.currentTheme),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ThemeScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 8),
          _buildSettingsGroup(
            context,
            children: [
              _buildSettingsTile(
                context: context,
                assetPath: 'assets/icons/info.png',
                title: 'EzCalc',
                subtitle: 'Version 1.0.0',
              ),
              _buildDivider(context),
              _buildSettingsTile(
                context: context,
                assetPath: 'assets/icons/developer.png',
                title: 'Developer',
                subtitle: 'Sakib',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DeveloperScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64.0, right: 16.0),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required String assetPath,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  assetPath,
                  width: 22,
                  height: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.system:
        return 'System Default';
      case AppTheme.cyberpunk:
        return 'Cyberpunk';
      case AppTheme.retro:
        return 'Retro Terminal';
      case AppTheme.nothing:
        return 'Nothing (Dark)';
      case AppTheme.nothingLight:
        return 'Nothing (Light)';
      case AppTheme.custom:
        return 'Custom Theme';
    }
  }
}
