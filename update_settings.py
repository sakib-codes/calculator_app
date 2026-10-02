import re

with open('lib/screens/settings_screen.dart', 'r') as f:
    content = f.read()

# Replace _buildSettingsTile signature
content = content.replace('''  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {''', '''  Widget _buildSettingsTile({
    required BuildContext context,
    required String assetPath,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {''')

# Replace the inner Icon widget with an Image.asset widget inside the container
content = content.replace('''                child: Icon(
                  icon,
                  size: 22,
                  color: colorScheme.onPrimaryContainer,
                ),''', '''                child: Image.asset(
                  assetPath,
                  width: 22,
                  height: 22,
                ),''')

# Replace usages
content = content.replace("icon: Icons.palette_outlined,", "assetPath: 'assets/icons/theme.png',")
content = content.replace("icon: Icons.info_outline,", "assetPath: 'assets/icons/info.png',")
content = content.replace("icon: Icons.code_rounded,", "assetPath: 'assets/icons/developer.png',")

with open('lib/screens/settings_screen.dart', 'w') as f:
    f.write(content)
