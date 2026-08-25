import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onQuickConverterTap;
  
  const AppDrawer({
    super.key,
    required this.onQuickConverterTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.calculate_rounded,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ultimate Calc',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), thickness: 1, height: 1),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'MODES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.calculate_outlined,
                    title: 'Standard',
                    isSelected: provider.mode == CalculatorMode.standard,
                    onTap: () {
                      if (provider.mode != CalculatorMode.standard) {
                        provider.setMode(CalculatorMode.standard);
                      }
                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.code,
                    title: 'Programmer',
                    isSelected: provider.mode == CalculatorMode.programmer,
                    onTap: () {
                      if (provider.mode != CalculatorMode.programmer) {
                        provider.setMode(CalculatorMode.programmer);
                      }
                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.science_outlined,
                    title: 'Scientific',
                    isSelected: provider.mode == CalculatorMode.scientific,
                    onTap: () {
                      if (provider.mode != CalculatorMode.scientific) {
                        provider.setMode(CalculatorMode.scientific);
                      }
                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), thickness: 1, height: 1),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'TOOLS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.swap_horiz,
                    title: 'Quick Converter',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      onQuickConverterTap();  // Open bottom sheet
                    },
                  ),
                  const Spacer(),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
