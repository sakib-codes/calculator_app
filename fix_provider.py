import re

with open('lib/providers/calculator_provider.dart', 'r') as f:
    content = f.read()

# Replace Decimal.tryParse(_input) ?? Decimal.zero
content = content.replace('Decimal.tryParse(_input) ?? Decimal.zero', '_parseInput(_input)')

# Add _parseInput method before formatNumber
parse_input_method = '''
  Decimal _parseInput(String input) {
    if (_mode == CalculatorMode.programmer) {
      int decValue = 0;
      try {
        if (_baseMode == BaseMode.hex) { decValue = int.parse(input, radix: 16); }
        else if (_baseMode == BaseMode.oct) { decValue = int.parse(input, radix: 8); }
        else if (_baseMode == BaseMode.bin) { decValue = int.parse(input, radix: 2); }
        else { decValue = int.parse(input); }
      } catch (_) { }
      return Decimal.parse(decValue.toString());
    }
    return Decimal.tryParse(input) ?? Decimal.zero;
  }

  String formatNumber(Decimal number) {
'''

content = content.replace('  String formatNumber(Decimal number) {\n', parse_input_method)

# Modify formatNumber to handle base modes
format_number_replacement = '''  String formatNumber(Decimal number) {
    if (_mode == CalculatorMode.programmer) {
      int val = number.toDouble().toInt();
      if (_baseMode == BaseMode.hex) return val.toRadixString(16).toUpperCase();
      if (_baseMode == BaseMode.oct) return val.toRadixString(8);
      if (_baseMode == BaseMode.bin) return val.toRadixString(2);
      return val.toString();
    }
    return number.toString();
  }'''

content = re.sub(
    r'  String formatNumber\(Decimal number\) \{\s*return number\.toString\(\);\s*\}',
    format_number_replacement,
    content
)

# In _calculate, formattedResult uses result.toString(). Let's change it to formatNumber(result)
content = content.replace('String formattedResult = result.toString();', 'String formattedResult = formatNumber(result);')

with open('lib/providers/calculator_provider.dart', 'w') as f:
    f.write(content)
