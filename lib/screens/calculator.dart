import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/calculator_button.dart';

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: AppDrawer(
        onQuickConverterTap: () => _showQuickConverter(context, provider),
      ),
      // Removed AppBar to avoid status bar overlap. Nav buttons are now manually placed in the body's SafeArea.
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            final char = event.character;
            final key = event.logicalKey;

            if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter || char == '=') {
              provider.buttonPress('=');
            } else if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
              provider.buttonPress('del');
            } else if (key == LogicalKeyboardKey.escape) {
              provider.buttonPress('AC');
            } else if (char == '*' || key == LogicalKeyboardKey.asterisk || key == LogicalKeyboardKey.numpadMultiply) {
              provider.buttonPress('×');
            } else if (char == '/' || key == LogicalKeyboardKey.slash || key == LogicalKeyboardKey.numpadDivide) {
              provider.buttonPress('÷');
            } else if (char == '-' || key == LogicalKeyboardKey.minus || key == LogicalKeyboardKey.numpadSubtract) {
              provider.buttonPress('-');
            } else if (char == '+' || key == LogicalKeyboardKey.add || key == LogicalKeyboardKey.numpadAdd) {
              provider.buttonPress('+');
            } else if (char == '.' || key == LogicalKeyboardKey.period || key == LogicalKeyboardKey.numpadDecimal) {
              provider.buttonPress('.');
            } else if (char == '%') {
              provider.buttonPress('%');
            } else if (char != null && RegExp(r'^[0-9a-fA-F]$').hasMatch(char)) {
              if (_isValidDigit(char.toUpperCase(), provider.baseMode)) {
                provider.buttonPress(char.toUpperCase());
              }
            }
          }
          return KeyEventResult.handled;
        },
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top Bar inside SafeArea to prevent status bar overlap
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.sort),
                        color: colorScheme.onSurface,
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history),
                      color: colorScheme.onSurface,
                      onPressed: () {
                        _showHistory(context, provider);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: (provider.mode != CalculatorMode.scientific && !isPortrait) ? 35 : 18,
                      child: _buildDisplayArea(context, provider),
                    ),
                    _buildDivider(context, isPortrait),
                    Expanded(
                      flex: (provider.mode != CalculatorMode.scientific && !isPortrait) ? 65 : 82,
                      child: _buildButtonGrid(context, provider, isPortrait),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context, bool isPortrait) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Divider(
          height: 2,
          thickness: 2,
          color: colorScheme.tertiary.withValues(alpha: 0.3)),
    );
  }

  Widget _buildDisplayArea(BuildContext context, CalculatorProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        provider.buttonPress('del');
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          provider.buttonPress('AC');
        }
      },
      child: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (provider.mode == CalculatorMode.standard)
                Text(
                  provider.operation != '0'
                      ? provider.operation.contains('=')
                          ? provider.operation
                          : '${provider.formatNumber(provider.getNum1)} ${provider.operation}'
                      : '',
                  style: TextStyle(
                    fontSize: 48,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 5),
              Text(
                provider.input,
                style: TextStyle(
                  fontSize: 96,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w300,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (provider.mode == CalculatorMode.programmer)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBaseRow(context, provider, 'HEX', BaseMode.hex),
                      _buildBaseRow(context, provider, 'DEC', BaseMode.dec),
                      _buildBaseRow(context, provider, 'OCT', BaseMode.oct),
                      _buildBaseRow(context, provider, 'BIN', BaseMode.bin),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonGrid(BuildContext context, CalculatorProvider provider, bool isPortrait) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          if (provider.mode == CalculatorMode.standard) ...[
            buildRow(context, provider, ['AC', 'C', '%', '÷'], forceCircle: isPortrait),
            buildRow(context, provider, ['1', '2', '3', '×'], forceCircle: isPortrait),
            buildRow(context, provider, ['4', '5', '6', '-'], forceCircle: isPortrait),
            buildRow(context, provider, ['7', '8', '9', '+'], forceCircle: isPortrait),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CalculatorButton(
                    onTap: () => provider.buttonPress('.'),
                    text: '.',
                    forceCircle: isPortrait,
                  ),
                  CalculatorButton(
                    onTap: () => provider.buttonPress('0'),
                    text: '0',
                    forceCircle: isPortrait,
                  ),
                  CalculatorButton(
                    onTap: () => provider.buttonPress('del'),
                    icon: Icons.backspace_outlined,
                    fontSize: 24,
                    forceCircle: isPortrait,
                  ),
                  CalculatorButton(
                    onTap: () => provider.buttonPress('='),
                    text: '=',
                    fontSize: 34,
                    isOperator: true,
                    forceCircle: isPortrait,
                  ),
                ],
              ),
            ),
          ] else if (provider.mode == CalculatorMode.scientific) ...[
            if (isPortrait) ...[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CalculatorButton(
                      onTap: () => provider.toggleAngleMode(),
                      text: provider.isDegrees ? 'DEG' : 'RAD',
                      fontSize: 18,
                      isSecondary: true,
                      forceCircle: false,
                    ),
                    _buildProgBtn(context, provider, provider.isInvMode ? 'asin' : 'sin', forceCircle: false),
                    _buildProgBtn(context, provider, provider.isInvMode ? 'acos' : 'cos', forceCircle: false),
                    _buildProgBtn(context, provider, provider.isInvMode ? 'atan' : 'tan', forceCircle: false),
                  ],
                ),
              ),
              buildRow(context, provider, ['ln', 'log', 'sqrt', '^'], forceCircle: false),
              buildRow(context, provider, ['π', 'e', '(', ')'], forceCircle: false),
              buildRow(context, provider, ['AC', 'C', '%', '÷'], forceCircle: false),
              buildRow(context, provider, ['1', '2', '3', '×'], forceCircle: false),
              buildRow(context, provider, ['4', '5', '6', '-'], forceCircle: false),
              buildRow(context, provider, ['7', '8', '9', '+'], forceCircle: false),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CalculatorButton(
                      onTap: () => provider.buttonPress('.'),
                      text: '.',
                      forceCircle: false,
                    ),
                    CalculatorButton(
                      onTap: () => provider.buttonPress('0'),
                      text: '0',
                      forceCircle: false,
                    ),
                    CalculatorButton(
                      onTap: () => provider.buttonPress('del'),
                      icon: Icons.backspace_outlined,
                      fontSize: 24,
                      forceCircle: false,
                    ),
                    CalculatorButton(
                      onTap: () => provider.buttonPress('='),
                      text: '=',
                      fontSize: 34,
                      isOperator: true,
                      forceCircle: false,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Landscape Scientific Grid (8 columns x 5 rows)
              buildRow(context, provider, ['DEG', provider.isInvMode ? 'asin' : 'sin', provider.isInvMode ? 'acos' : 'cos', provider.isInvMode ? 'atan' : 'tan', 'AC', 'C', '%', '÷'], forceCircle: false),
              buildRow(context, provider, ['ln', 'log', 'sqrt', '^', '7', '8', '9', '×'], forceCircle: false),
              buildRow(context, provider, ['π', 'e', '(', ')', '4', '5', '6', '-'], forceCircle: false),
              buildRow(context, provider, ['x²', '1/x', '!', 'inv', '1', '2', '3', '+'], forceCircle: false), // Extra buttons to fill row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgBtn(context, provider, 'abs', flex: 1, forceCircle: false),
                    _buildProgBtn(context, provider, 'sgn', flex: 1, forceCircle: false),
                    _buildProgBtn(context, provider, 'ceil', flex: 1, forceCircle: false),
                    _buildProgBtn(context, provider, 'floor', flex: 1, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('0'), text: '0', fontSize: 21, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('.'), text: '.', fontSize: 21, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('del'), icon: Icons.backspace_outlined, fontSize: 18, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('='), text: '=', fontSize: 26, isOperator: true, forceCircle: false),
                  ],
                ),
              ),
            ],
          ] else ...[
            buildRow(context, provider, ['D', 'E', 'F', 'AC'], forceCircle: true),
            buildRow(context, provider, ['A', 'B', 'C', 'del'], forceCircle: true),
            buildRow(context, provider, ['7', '8', '9', '÷'], forceCircle: true),
            buildRow(context, provider, ['4', '5', '6', '×'], forceCircle: true),
            buildRow(context, provider, ['1', '2', '3', '-'], forceCircle: true),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgBtn(context, provider, '0', flex: 2),
                  _buildProgBtn(context, provider, '='),
                  _buildProgBtn(context, provider, '+'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgBtn(BuildContext context, CalculatorProvider provider, String label, {int flex = 1, bool forceCircle = true}) {
    bool isOperator = label == '=' || label == '+';
    bool isValid = _isValidDigit(label, provider.baseMode) || provider.mode == CalculatorMode.scientific;

    double fontSize = 28;
    if (isOperator) fontSize = 34;
    if (['sin', 'cos', 'tan', 'log', 'sqrt', 'ln', 'inv', 'abs', 'sgn', 'ceil', 'floor'].contains(label)) fontSize = 20;
    if (label == 'DEG' || label == 'RAD') fontSize = 18;
    if (['(', ')', 'π', 'e', '^', 'x²', '1/x', '!'].contains(label)) fontSize = 24;

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      fontSize *= 0.75;
    }

    return CalculatorButton(
      flex: flex,
      onTap: isValid ? () => label == 'DEG' ? provider.toggleAngleMode() : provider.buttonPress(label) : () {},
      text: label == 'DEG' ? (provider.isDegrees ? 'DEG' : 'RAD') : label,
      fontSize: fontSize,
      isOperator: isOperator,
      textColor: isValid ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
      forceCircle: forceCircle,
    );
  }

  Widget buildRow(
      BuildContext context, CalculatorProvider provider, List<String> labels, {bool forceCircle = true}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(labels.length, (index) {
          final label = labels[index];
          final isOperator = ['÷', '×', '-', '+', '='].contains(label);
          final isSecondary = ['AC', 'C', '%'].contains(label);

          double fontSize = 28;
          if (isOperator) fontSize = 34;
          if (label == 'AC' || label == 'C' || label == 'del') fontSize = 24;
          if (['sin', 'cos', 'tan', 'log', 'sqrt', 'ln', 'inv', 'abs', 'sgn', 'ceil', 'floor'].contains(label)) fontSize = 20;
          if (label == 'DEG' || label == 'RAD') fontSize = 18;
          if (['(', ')', 'π', 'e', '^', 'x²', '1/x', '!'].contains(label)) fontSize = 24;

          if (MediaQuery.of(context).orientation == Orientation.landscape) {
            fontSize *= 0.75;
          }

          bool isActive = false;
          if (isOperator &&
              provider.operation == label &&
              provider.input == '0') {
            isActive = true;
          }
          if (label == 'inv' && provider.isInvMode) {
            isActive = true;
          }

          Color? textColor;
          if (isSecondary) {
            textColor = Colors.orangeAccent;
          }

          bool isValid = _isValidDigit(label, provider.baseMode) || provider.mode == CalculatorMode.standard || provider.mode == CalculatorMode.scientific;
          if (!isValid) {
            // Updated alpha from 0.2 to 0.35 for better disabled contrast
            textColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);
          }

          return CalculatorButton(
            onTap: isValid ? () => provider.buttonPress(label) : () {},
            text: label == 'del' ? null : label,
            icon: label == 'del' ? Icons.backspace_outlined : null,
            fontSize: fontSize,
            isOperator: isOperator,
            isSecondary: isSecondary,
            isActive: isActive,
            textColor: textColor,
            forceCircle: forceCircle,
          );
        }),
      ),
    );
  }

  bool _isValidDigit(String label, BaseMode mode) {
    if (['AC', 'C', 'del', '=', '+', '-', '×', '÷'].contains(label)) return true;
    if (mode == BaseMode.hex) return RegExp(r'^[0-9A-F]$').hasMatch(label);
    if (mode == BaseMode.dec) return RegExp(r'^[0-9]$').hasMatch(label);
    if (mode == BaseMode.oct) return RegExp(r'^[0-7]$').hasMatch(label);
    if (mode == BaseMode.bin) return RegExp(r'^[0-1]$').hasMatch(label);
    return false;
  }

  Widget _buildBaseRow(BuildContext context, CalculatorProvider provider, String label, BaseMode mode) {
    bool isSelected = provider.baseMode == mode;
    String value = _convertInput(provider.input, provider.baseMode, mode);
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () => provider.setBaseMode(mode),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(
              width: 45,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                color: isSelected ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _convertInput(String input, BaseMode currentMode, BaseMode targetMode) {
    if (input == 'Error' || input == '0') return input;
    int decValue = 0;
    try {
      if (currentMode == BaseMode.hex) { decValue = int.parse(input, radix: 16); }
      else if (currentMode == BaseMode.oct) { decValue = int.parse(input, radix: 8); }
      else if (currentMode == BaseMode.bin) { decValue = int.parse(input, radix: 2); }
      else { decValue = int.parse(input); }
    } catch (_) { return '0'; }
    if (targetMode == BaseMode.hex) { return decValue.toRadixString(16).toUpperCase(); }
    if (targetMode == BaseMode.oct) { return decValue.toRadixString(8); }
    if (targetMode == BaseMode.bin) { return decValue.toRadixString(2); }
    return decValue.toString();
  }

  void _showHistory(BuildContext context, CalculatorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.clearHistory();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: provider.history.isEmpty
                    ? Center(
                        child: Text(
                          'No history yet',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.history.length,
                        itemBuilder: (context, index) {
                          final calculation = provider.history[index];
                          return ListTile(
                            title: Text(
                              calculation,
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            onTap: () {
                              provider.loadHistory(calculation);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickConverter(BuildContext context, CalculatorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final val = double.tryParse(provider.input) ?? 0.0;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Converter',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Text('Length', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ListTile(title: const Text('Kilometers to Miles'), trailing: Text('${(val * 0.621371).toStringAsFixed(2)} mi')),
              ListTile(title: const Text('Miles to Kilometers'), trailing: Text('${(val * 1.60934).toStringAsFixed(2)} km')),
              const Divider(),
              Text('Mass', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ListTile(title: const Text('Kilograms to Pounds'), trailing: Text('${(val * 2.20462).toStringAsFixed(2)} lb')),
              ListTile(title: const Text('Pounds to Kilograms'), trailing: Text('${(val * 0.453592).toStringAsFixed(2)} kg')),
              const Divider(),
              Text('Temperature', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ListTile(title: const Text('Celsius to Fahrenheit'), trailing: Text('${((val * 9/5) + 32).toStringAsFixed(2)} °F')),
              ListTile(title: const Text('Fahrenheit to Celsius'), trailing: Text('${((val - 32) * 5/9).toStringAsFixed(2)} °C')),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
