import re

with open('lib/screens/custom_theme_editor.dart', 'r') as f:
    content = f.read()

# Fix backslashes in string interpolation
content = content.replace('\\$', '$')

# Fix FilePicker type
content = content.replace(
    '''      List<PlatformFile>? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf'],
      );
      if (result != null && result.isNotEmpty && result.first.path != null) {
        File sourceFile = File(result.first.path!);''',
    '''      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf'],
      );
      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        File sourceFile = File(result.files.first.path!);'''
)
content = content.replace('String fileName = result.first.name;', 'String fileName = result.files.first.name;')

# Fix withOpacity deprecation
content = content.replace('withOpacity(', 'withValues(alpha: ')

with open('lib/screens/custom_theme_editor.dart', 'w') as f:
    f.write(content)
