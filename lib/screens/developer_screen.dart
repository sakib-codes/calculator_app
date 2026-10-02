import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.developer_mode,
                size: 60,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Abu Bakkar Siddique Sakib',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRoleChip(context, 'Flutter Developer'),
              _buildRoleChip(context, 'AI Automation'),
              _buildRoleChip(context, 'Software Eng.'),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'About Me',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'I am a software developer passionate about building efficient software and automation systems. My programming journey started with C and C++, where I developed strong problem-solving skills through Data Structures and Algorithms. I later explored Python for automation and AI experimentation. Currently, I am focused on Flutter mobile app development while continuing to work with API integrations, automation systems, and AI-related workflows.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildLinkButton(
                  context: context,
                  icon: Image.asset('assets/icons/web.png', width: 20, height: 20),
                  label: 'Website',
                  url: 'https://sakibcodes.com',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLinkButton(
                  context: context,
                  icon: const FaIcon(FontAwesomeIcons.github, size: 20),
                  label: 'GitHub',
                  url: 'https://github.com/sakib-codes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.star_rounded, color: colorScheme.primary),
                  title: const Text('EzCalc'),
                  subtitle: const Text('Version 1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton({
    required BuildContext context,
    required Widget icon,
    required String label,
    required String url,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: () => _launchUrl(url),
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildRoleChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
