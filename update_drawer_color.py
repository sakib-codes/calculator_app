import re

with open('lib/widgets/app_drawer.dart', 'r') as f:
    content = f.read()

# Remove color from header icon
content = content.replace('''                            child: Image.asset(
                              'assets/icons/calculator icon.png',
                              color: colorScheme.primary,
                            ),''', '''                            child: Image.asset(
                              'assets/icons/calculator icon.png',
                            ),''')

# Remove color from list tile icons
content = content.replace('''        leading: Image.asset(
          assetPath,
          width: 24,
          height: 24,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
        ),''', '''        leading: Image.asset(
          assetPath,
          width: 24,
          height: 24,
        ),''')

with open('lib/widgets/app_drawer.dart', 'w') as f:
    f.write(content)
