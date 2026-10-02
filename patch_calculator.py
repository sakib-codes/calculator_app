import re

with open('lib/screens/calculator.dart', 'r') as f:
    content = f.read()

if "import '../widgets/quick_converter.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../widgets/quick_converter.dart';")

content = re.sub(
    r'void _showQuickConverter\(BuildContext context, CalculatorProvider provider\) \{.*',
    '''void _showQuickConverter(BuildContext context, CalculatorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 24, // Leave space for status bar
          ),
          child: QuickConverterSheet(
            initialValue: provider.input.isEmpty || provider.input == 'Error' ? '0' : provider.input,
          ),
        );
      },
    );
  }
}''',
    content,
    flags=re.DOTALL
)

with open('lib/screens/calculator.dart', 'w') as f:
    f.write(content)
