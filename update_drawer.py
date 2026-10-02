import re

with open('lib/widgets/app_drawer.dart', 'r') as f:
    content = f.read()

# Replace header icon
content = content.replace('''                          child: Icon(
                            Icons.calculate_rounded,
                            size: 32,
                            color: colorScheme.primary,
                          ),''', '''                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'assets/icons/calculator icon.png',
                              color: colorScheme.primary,
                            ),
                          ),''')

# Replace _buildDrawerItem signature
content = content.replace('''  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {''', '''  Widget _buildDrawerItem({
    required BuildContext context,
    required String assetPath,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {''')

# Replace leading Icon with Image.asset
content = content.replace('''        leading: Icon(
          icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
        ),''', '''        leading: Image.asset(
          assetPath,
          width: 24,
          height: 24,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
        ),''')

# Replace usages
replacements = {
    "icon: Icons.calculate_rounded,": "assetPath: 'assets/icons/calculator icon.png',",
    "icon: Icons.terminal_rounded,": "assetPath: 'assets/icons/terminal.png',",
    "icon: Icons.functions_rounded,": "assetPath: 'assets/icons/seientific.png',",
    "icon: Icons.calendar_month_rounded,": "assetPath: 'assets/icons/time & age.png',",
    "icon: Icons.sync_alt_rounded,": "assetPath: 'assets/icons/converter.png',",
    "icon: Icons.settings_rounded,": "assetPath: 'assets/icons/settings.png',",
}

for old, new in replacements.items():
    content = content.replace(old, new)

with open('lib/widgets/app_drawer.dart', 'w') as f:
    f.write(content)
