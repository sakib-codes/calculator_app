import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/custom_theme_model.dart';
import '../providers/theme_provider.dart';

class CustomThemeEditorScreen extends StatefulWidget {
  const CustomThemeEditorScreen({super.key});

  @override
  State<CustomThemeEditorScreen> createState() => _CustomThemeEditorScreenState();
}

class _CustomThemeEditorScreenState extends State<CustomThemeEditorScreen> {
  late CustomThemeModel _tempModel;

  @override
  void initState() {
    super.initState();
    // Create a copy of the current custom theme to edit
    final currentCustom = Provider.of<ThemeProvider>(context, listen: false).customTheme;
    _tempModel = CustomThemeModel(
      primaryColor: currentCustom.primaryColor,
      surfaceColor: currentCustom.surfaceColor,
      onSurfaceColor: currentCustom.onSurfaceColor,
      backgroundColor: currentCustom.backgroundColor,
      fontFamily: currentCustom.fontFamily,
      fontPath: currentCustom.fontPath,
    );
  }

  void _pickColor(BuildContext context, String title, Color currentColor, ValueChanged<Color> onColorChanged) {
    Color pickerColor = currentColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => pickerColor = color,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFont() async {
    try {
      List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf'],
      );
      if (result.isNotEmpty && result.first.path != null) {
        File sourceFile = File(result.first.path!);
        Directory appDocDir = await getApplicationDocumentsDirectory();
        
        // Generate a simple family name based on filename
        String fileName = result.first.name;
        String familyName = fileName.replaceAll('.ttf', '').replaceAll('.otf', '').replaceAll(' ', '');
        
        String newPath = '${appDocDir.path}/$fileName';
        await sourceFile.copy(newPath);
        
        setState(() {
          _tempModel.fontPath = newPath;
          _tempModel.fontFamily = familyName;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Font $fileName imported!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import font: $e')),
        );
      }
    }
  }

  void _saveAndApply() {
    Provider.of<ThemeProvider>(context, listen: false).updateCustomTheme(_tempModel);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Custom Theme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndApply,
            tooltip: 'Save & Apply',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Colors',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildColorTile('Background Color', _tempModel.backgroundColor, (c) => setState(() => _tempModel.backgroundColor = c)),
          _buildColorTile('Primary Color', _tempModel.primaryColor, (c) => setState(() => _tempModel.primaryColor = c)),
          _buildColorTile('Surface Color (Cards)', _tempModel.surfaceColor, (c) => setState(() => _tempModel.surfaceColor = c)),
          _buildColorTile('Text Color', _tempModel.onSurfaceColor, (c) => setState(() => _tempModel.onSurfaceColor = c)),
          
          const SizedBox(height: 32),
          const Text(
            'Typography',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Custom Font'),
            subtitle: Text(_tempModel.fontFamily ?? 'System Default'),
            trailing: const Icon(Icons.file_upload),
            onTap: _pickFont,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Theme.of(context).colorScheme.surface,
          ),
          if (_tempModel.fontFamily != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                icon: const Icon(Icons.clear, color: Colors.red),
                label: const Text('Clear Custom Font', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  setState(() {
                    _tempModel.fontFamily = null;
                    _tempModel.fontPath = null;
                  });
                },
              ),
            ),
            
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _saveAndApply,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: _tempModel.primaryColor,
              foregroundColor: _tempModel.backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            ),
            child: const Text('Save & Apply Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTile(String title, Color color, ValueChanged<Color> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text(title),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 1),
          ),
        ),
        onTap: () => _pickColor(context, title, color, onChanged),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
