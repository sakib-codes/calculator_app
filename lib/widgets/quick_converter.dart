import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickConverterScreen extends StatefulWidget {
  final String initialValue;

  const QuickConverterScreen({super.key, required this.initialValue});

  @override
  State<QuickConverterScreen> createState() => _QuickConverterScreenState();
}

class _QuickConverterScreenState extends State<QuickConverterScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _inputController;
  double _inputValue = 0.0;
  int _selectedCategory = 0;
  int _fromUnit = 0;
  int _toUnit = 1;

  // Categories and their units
  static const List<_Category> _categories = [
    _Category('Length', Icons.straighten_rounded, [
      _Unit('Kilometers', 'km', 1000),
      _Unit('Meters', 'm', 1),
      _Unit('Centimeters', 'cm', 0.01),
      _Unit('Millimeters', 'mm', 0.001),
      _Unit('Miles', 'mi', 1609.344),
      _Unit('Feet', 'ft', 0.3048),
      _Unit('Inches', 'in', 0.0254),
      _Unit('Yards', 'yd', 0.9144),
    ]),
    _Category('Mass', Icons.scale_rounded, [
      _Unit('Kilograms', 'kg', 1),
      _Unit('Grams', 'g', 0.001),
      _Unit('Milligrams', 'mg', 0.000001),
      _Unit('Pounds', 'lb', 0.453592),
      _Unit('Ounces', 'oz', 0.0283495),
      _Unit('Tons', 't', 1000),
    ]),
    _Category('Temperature', Icons.thermostat_rounded, [
      _Unit('Celsius', '°C', 1),
      _Unit('Fahrenheit', '°F', 1),
      _Unit('Kelvin', 'K', 1),
    ]),
    _Category('Volume', Icons.water_drop_rounded, [
      _Unit('Liters', 'L', 1),
      _Unit('Milliliters', 'mL', 0.001),
      _Unit('Gallons (US)', 'gal', 3.78541),
      _Unit('Cups', 'cup', 0.236588),
      _Unit('Fluid Oz', 'fl oz', 0.0295735),
    ]),
    _Category('Speed', Icons.speed_rounded, [
      _Unit('km/h', 'km/h', 1),
      _Unit('m/s', 'm/s', 3.6),
      _Unit('mph', 'mph', 1.60934),
      _Unit('Knots', 'kn', 1.852),
    ]),
    _Category('Data', Icons.storage_rounded, [
      _Unit('Bytes', 'B', 1),
      _Unit('Kilobytes', 'KB', 1024),
      _Unit('Megabytes', 'MB', 1048576),
      _Unit('Gigabytes', 'GB', 1073741824),
      _Unit('Terabytes', 'TB', 1099511627776),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue == '0' ? '' : widget.initialValue;
    _inputController = TextEditingController(text: initial);
    _inputValue = double.tryParse(widget.initialValue) ?? 0.0;
    _inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {
      _inputValue = double.tryParse(_inputController.text) ?? 0.0;
    });
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    HapticFeedback.lightImpact();
  }

  double _convert() {
    final cat = _categories[_selectedCategory];
    final from = cat.units[_fromUnit];
    final to = cat.units[_toUnit];

    // Special handling for temperature
    if (cat.name == 'Temperature') {
      return _convertTemperature(_inputValue, from.symbol, to.symbol);
    }

    // Standard conversion: value * (from_factor / to_factor)
    return _inputValue * (from.factor / to.factor);
  }

  double _convertTemperature(double value, String from, String to) {
    if (from == to) return value;
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case '°C':
        celsius = value;
        break;
      case '°F':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'K':
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }
    // Convert from Celsius to target
    switch (to) {
      case '°C':
        return celsius;
      case '°F':
        return (celsius * 9 / 5) + 32;
      case 'K':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  String _formatResult(double value) {
    if (value == 0) return '0';
    if (value.abs() >= 1000000) {
      return value.toStringAsExponential(4);
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    // Remove trailing zeros
    String s = value.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cat = _categories[_selectedCategory];
    final result = _convert();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Quick Converter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Category Chips ---
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final c = _categories[index];
                  final isSelected = index == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = index;
                        _fromUnit = 0;
                        _toUnit = 1;
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.icon,
                              size: 14,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- Converter Body ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color:
                          colorScheme.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    // FROM row
                    _buildUnitRow(
                      context,
                      label: 'From',
                      controller: _inputController,
                      unitIndex: _fromUnit,
                      units: cat.units,
                      isInput: true,
                      onUnitChanged: (i) => setState(() => _fromUnit = i),
                    ),

                    // Swap button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.2)),
                          ),
                          GestureDetector(
                            onTap: _swapUnits,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.2)),
                              ),
                              child: Icon(Icons.swap_vert_rounded,
                                  size: 20, color: colorScheme.primary),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.2)),
                          ),
                        ],
                      ),
                    ),

                    // TO row (result)
                    _buildResultRow(
                      context,
                      label: 'To',
                      result: _formatResult(result),
                      unitIndex: _toUnit,
                      units: cat.units,
                      onUnitChanged: (i) => setState(() => _toUnit = i),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Quick Reference Grid ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildQuickReference(context, cat),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitRow(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required int unitIndex,
    required List<_Unit> units,
    required bool isInput,
    required ValueChanged<int> onUnitChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Unit Dropdown
        GestureDetector(
          onTap: () => _showUnitPicker(context, units, unitIndex, onUnitChanged),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  units[unitIndex].symbol,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: colorScheme.primary),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Input field
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
            ],
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(
    BuildContext context, {
    required String label,
    required String result,
    required int unitIndex,
    required List<_Unit> units,
    required ValueChanged<int> onUnitChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Unit Dropdown
        GestureDetector(
          onTap: () => _showUnitPicker(context, units, unitIndex, onUnitChanged),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  units[unitIndex].symbol,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: colorScheme.secondary),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Result display
        Expanded(
          child: Text(
            result,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReference(BuildContext context, _Category cat) {
    final colorScheme = Theme.of(context).colorScheme;
    // Show a few common conversions for the selected category
    final from = cat.units[_fromUnit];
    final to = cat.units[_toUnit];
    final refs = [1.0, 5.0, 10.0, 50.0, 100.0];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.table_chart_rounded,
                  size: 12, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Quick Reference',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: refs.map((v) {
              double converted;
              if (cat.name == 'Temperature') {
                converted =
                    _convertTemperature(v, from.symbol, to.symbol);
              } else {
                converted = v * (from.factor / to.factor);
              }
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: colorScheme.outlineVariant
                          .withValues(alpha: 0.15)),
                ),
                child: Text(
                  '${v.toInt()} ${from.symbol} = ${_formatResult(converted)} ${to.symbol}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showUnitPicker(BuildContext context, List<_Unit> units,
      int currentIndex, ValueChanged<int> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Select Unit',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              ...List.generate(units.length, (i) {
                final u = units[i];
                final isSelected = i == currentIndex;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      u.symbol,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  title: Text(u.name,
                      style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded,
                          color: colorScheme.primary, size: 22)
                      : null,
                  onTap: () {
                    onChanged(i);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _Category {
  final String name;
  final IconData icon;
  final List<_Unit> units;

  const _Category(this.name, this.icon, this.units);
}

class _Unit {
  final String name;
  final String symbol;
  final double factor; // factor to base unit

  const _Unit(this.name, this.symbol, this.factor);
}
