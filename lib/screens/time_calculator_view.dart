import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';

class TimeCalculatorView extends StatefulWidget {
  const TimeCalculatorView({super.key});

  @override
  State<TimeCalculatorView> createState() => _TimeCalculatorViewState();
}

class _TimeCalculatorViewState extends State<TimeCalculatorView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Difference Tab State ---
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 365 * 20));
  DateTime _toDate = DateTime.now();
  bool _isToDateNow = true;
  Timer? _timer;

  int _diffYears = 0, _diffMonths = 0, _diffDays = 0;
  int _totalMonths = 0, _totalWeeks = 0, _totalDays = 0;
  int _totalHours = 0, _totalMinutes = 0, _totalSeconds = 0;

  // --- Add/Subtract Tab State ---
  bool _isAdding = true;

  // Add Fields (Time 2)
  int _addYears = 0, _addMonths = 0, _addDays = 0;
  int _addHours = 0, _addMins = 0, _addSecs = 0;

  final TextEditingController _addYearsCtrl = TextEditingController();
  final TextEditingController _addMonthsCtrl = TextEditingController();
  final TextEditingController _addDaysCtrl = TextEditingController();
  final TextEditingController _addHoursCtrl = TextEditingController();
  final TextEditingController _addMinsCtrl = TextEditingController();
  final TextEditingController _addSecsCtrl = TextEditingController();

  // Base Fields (Time 1)
  int _baseYears = 0, _baseMonths = 0, _baseDays = 0;
  int _baseHours = 0, _baseMins = 0, _baseSecs = 0;

  final TextEditingController _baseYearsCtrl = TextEditingController();
  final TextEditingController _baseMonthsCtrl = TextEditingController();
  final TextEditingController _baseDaysCtrl = TextEditingController();
  final TextEditingController _baseHoursCtrl = TextEditingController();
  final TextEditingController _baseMinsCtrl = TextEditingController();
  final TextEditingController _baseSecsCtrl = TextEditingController();

  // Result fields
  int _resYears = 0, _resMonths = 0, _resDays = 0;
  int _resHours = 0, _resMins = 0, _resSecs = 0;
  bool _resIsNegative = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateDifference();
    _calculateResult();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isToDateNow) {
        setState(() {
          _toDate = DateTime.now();
          _calculateDifference();
        });
      }
    });
  }

  @override
  void dispose() {
    _addYearsCtrl.dispose(); _addMonthsCtrl.dispose(); _addDaysCtrl.dispose();
    _addHoursCtrl.dispose(); _addMinsCtrl.dispose(); _addSecsCtrl.dispose();
    _baseYearsCtrl.dispose(); _baseMonthsCtrl.dispose(); _baseDaysCtrl.dispose();
    _baseHoursCtrl.dispose(); _baseMinsCtrl.dispose(); _baseSecsCtrl.dispose();
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // --- Logic for Difference Tab ---
  void _calculateDifference() {
    DateTime from = _fromDate;
    DateTime to = _toDate;
    
    if (from.isAfter(to)) {
      final temp = from;
      from = to;
      to = temp;
    }

    int years = to.year - from.year;
    int months = to.month - from.month;
    int days = to.day - from.day;

    if (days < 0) {
      months--;
      int prevMonth = to.month - 1;
      int year = to.year;
      if (prevMonth == 0) {
        prevMonth = 12;
        year--;
      }
      days += _daysInMonth(year, prevMonth);
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final difference = to.difference(from);
    
    _diffYears = years;
    _diffMonths = months;
    _diffDays = days;

    _totalDays = difference.inDays;
    _totalWeeks = (_totalDays / 7).floor();
    _totalMonths = (years * 12) + months;
    _totalHours = difference.inHours;
    _totalMinutes = difference.inMinutes;
    _totalSeconds = difference.inSeconds;
    
    if (mounted) {
      setState(() {});
    }
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  Future<void> _selectDiffDate(BuildContext context, bool isFromDate) async {
    final DateTime initialDate = isFromDate ? _fromDate : _toDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('en', 'GB'),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
          _isToDateNow = false;
        }
        _calculateDifference();
      });
    }
  }

  // --- Logic for Add/Subtract Tab ---
  void _calculateResult() {
    setState(() {
      int sign = _isAdding ? 1 : -1;
      int totalSecs = _baseSecs + (_addSecs * sign);
      int totalMins = _baseMins + (_addMins * sign);
      int totalHours = _baseHours + (_addHours * sign);
      int totalDays = _baseDays + (_addDays * sign);
      int totalMonths = _baseMonths + (_addMonths * sign);
      int totalYears = _baseYears + (_addYears * sign);

      int totalAbstractSeconds = 
        totalSecs + 
        totalMins * 60 + 
        totalHours * 3600 + 
        totalDays * 86400 + 
        totalMonths * 30 * 86400 + 
        totalYears * 365 * 86400;

      if (totalAbstractSeconds < 0) {
        _resIsNegative = true;
        totalAbstractSeconds = -totalAbstractSeconds;
      } else {
        _resIsNegative = false;
      }

      _resSecs = totalAbstractSeconds % 60;
      int remMins = totalAbstractSeconds ~/ 60;
      _resMins = remMins % 60;
      int remHours = remMins ~/ 60;
      _resHours = remHours % 24;
      int remDays = remHours ~/ 24;

      int remMonths = remDays ~/ 30; // abstract approx
      _resDays = remDays % 30;
      
      _resYears = remMonths ~/ 12;
      _resMonths = remMonths % 12;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Difference'),
                Tab(text: 'Add/Subtract'),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDifferenceTab(context),
              _buildAddSubtractTab(context),
            ],
          ),
        ),
      ],
    );
  }


  // --- DIFFERENCE TAB UI ---
  Widget _buildDifferenceTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // --- Date Pickers in a compact row ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                _buildCompactDateRow(
                  context,
                  label: 'From',
                  date: _fromDate,
                  icon: Icons.event_rounded,
                  onTap: () => _selectDiffDate(context, true),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 32),
                      Icon(Icons.arrow_downward_rounded, size: 14, color: colorScheme.primary.withValues(alpha: 0.5)),
                      const SizedBox(width: 8),
                      Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.2))),
                    ],
                  ),
                ),
                _buildCompactDateRow(
                  context,
                  label: 'To',
                  date: _toDate,
                  icon: Icons.event_available_rounded,
                  onTap: () => _selectDiffDate(context, false),
                  isLive: _isToDateNow,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- Primary Result: Years / Months / Days ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.08),
                  colorScheme.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPrimaryUnit(context, _diffYears, 'Years'),
                    _buildDividerDot(context),
                    _buildPrimaryUnit(context, _diffMonths, 'Months'),
                    _buildDividerDot(context),
                    _buildPrimaryUnit(context, _diffDays, 'Days'),
                  ],
                ),
                if (_isToDateNow) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text('Live — updates every second', style: TextStyle(fontSize: 9, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- Breakdown Grid ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('Breakdown', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorScheme.primary, letterSpacing: 0.8)),
                  ],
                ),
                const SizedBox(height: 12),
                // Row 1: Months, Weeks
                Row(
                  children: [
                    Expanded(child: _buildBreakdownTile(context, _totalMonths, 'Months', Icons.calendar_view_month_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildBreakdownTile(context, _totalWeeks, 'Weeks', Icons.view_week_rounded)),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 2: Days, Hours
                Row(
                  children: [
                    Expanded(child: _buildBreakdownTile(context, _totalDays, 'Days', Icons.today_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildBreakdownTile(context, _totalHours, 'Hours', Icons.schedule_rounded)),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 3: Minutes, Seconds
                Row(
                  children: [
                    Expanded(child: _buildBreakdownTile(context, _totalMinutes, 'Minutes', Icons.timelapse_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildBreakdownTile(context, _totalSeconds, 'Seconds', Icons.timer_rounded)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompactDateRow(BuildContext context, {required String label, required DateTime date, required IconData icon, required VoidCallback onTap, bool isLive = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final formattedTime = DateFormat('HH:mm:ss').format(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
                      if (isLive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('NOW', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.green.shade700, letterSpacing: 0.5)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(formattedDate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      if (isLive) ...[
                        Text('  ', style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                        Text(formattedTime, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.primary.withValues(alpha: 0.7))),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 16, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryUnit(BuildContext context, int value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: value > 999 ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 0.3)),
      ],
    );
  }

  Widget _buildDividerDot(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 4, height: 4,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBreakdownTile(BuildContext context, int value, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatted = _formatNumber(value);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 0.3)),
                const SizedBox(height: 1),
                Text(formatted, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000000) return '${(n / 1000000000).toStringAsFixed(1)}B';
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 100000) return '${(n / 1000).toStringAsFixed(1)}K';
    final str = n.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return result.toString();
  }


  // --- ADD/SUBTRACT TAB UI ---
  Widget _buildAddSubtractTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // --- TIME 1 Section ---
          _buildTimeSection(context, title: 'Duration 1', icon: Icons.timer_outlined, isBase: true),
          const SizedBox(height: 12),
          // --- Operation Toggle ---
          _buildOperationToggle(context),
          const SizedBox(height: 12),
          // --- TIME 2 Section ---
          _buildTimeSection(context, title: 'Duration 2', icon: Icons.more_time_rounded, isBase: false),
          const SizedBox(height: 16),
          // --- Equals Divider ---
          Row(
            children: [
              Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('=', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                ),
              ),
              Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
            ],
          ),
          const SizedBox(height: 16),
          // --- Result ---
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            ),
            child: _buildResultCard(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimeSection(BuildContext context, {required String title, required IconData icon, required bool isBase}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorScheme.primary, letterSpacing: 0.8)),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    if (isBase) {
                      _baseYears = 0; _baseMonths = 0; _baseDays = 0;
                      _baseHours = 0; _baseMins = 0; _baseSecs = 0;
                      _baseYearsCtrl.clear(); _baseMonthsCtrl.clear(); _baseDaysCtrl.clear();
                      _baseHoursCtrl.clear(); _baseMinsCtrl.clear(); _baseSecsCtrl.clear();
                    } else {
                      _addYears = 0; _addMonths = 0; _addDays = 0;
                      _addHours = 0; _addMins = 0; _addSecs = 0;
                      _addYearsCtrl.clear(); _addMonthsCtrl.clear(); _addDaysCtrl.clear();
                      _addHoursCtrl.clear(); _addMinsCtrl.clear(); _addSecsCtrl.clear();
                    }
                    _calculateResult();
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text('Clear', style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildCompactInputRow(context, isBase),
        ],
      ),
    );
  }

  Widget _buildCompactInputRow(BuildContext context, bool isBase) {
    final labels = ['Yr', 'Mo', 'Dy', 'Hr', 'Mi', 'Se'];
    final controllers = isBase
        ? [_baseYearsCtrl, _baseMonthsCtrl, _baseDaysCtrl, _baseHoursCtrl, _baseMinsCtrl, _baseSecsCtrl]
        : [_addYearsCtrl, _addMonthsCtrl, _addDaysCtrl, _addHoursCtrl, _addMinsCtrl, _addSecsCtrl];

    return Row(
      children: List.generate(labels.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 3, right: i == labels.length - 1 ? 0 : 3),
            child: _buildCompactField(context, labels[i], controllers[i], isBase, i),
          ),
        );
      }),
    );
  }

  Widget _buildCompactField(BuildContext context, String label, TextEditingController controller, bool isBase, int fieldIndex) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDateField = fieldIndex < 3;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDateField
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.secondary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: isDateField
                  ? colorScheme.primary.withValues(alpha: 0.08)
                  : colorScheme.secondary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(9), topRight: Radius.circular(9)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isDateField ? colorScheme.primary : colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          TextField(
            key: ValueKey('${isBase ? "b" : "a"}_$label'),
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              hintText: '0',
              hintStyle: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.2), fontWeight: FontWeight.w400),
            ),
            onChanged: (val) {
              int parsed = int.tryParse(val) ?? 0;
              setState(() {
                if (isBase) {
                  switch (fieldIndex) {
                    case 0: _baseYears = parsed;
                    case 1: _baseMonths = parsed;
                    case 2: _baseDays = parsed;
                    case 3: _baseHours = parsed;
                    case 4: _baseMins = parsed;
                    case 5: _baseSecs = parsed;
                  }
                } else {
                  switch (fieldIndex) {
                    case 0: _addYears = parsed;
                    case 1: _addMonths = parsed;
                    case 2: _addDays = parsed;
                    case 3: _addHours = parsed;
                    case 4: _addMins = parsed;
                    case 5: _addSecs = parsed;
                  }
                }
                _calculateResult();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOperationToggle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleOption(context, icon: Icons.add_rounded, label: 'Add', isSelected: _isAdding, onTap: () {
              if (!_isAdding) setState(() { _isAdding = true; _calculateResult(); });
            }),
            const SizedBox(width: 4),
            _buildToggleOption(context, icon: Icons.remove_rounded, label: 'Subtract', isSelected: !_isAdding, onTap: () {
              if (_isAdding) setState(() { _isAdding = false; _calculateResult(); });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(BuildContext context, {required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isNeg = _resIsNegative;
    final Color accentColor = isNeg ? colorScheme.error : colorScheme.primary;

    final results = [
      {'value': _resYears, 'label': 'Years'},
      {'value': _resMonths, 'label': 'Months'},
      {'value': _resDays, 'label': 'Days'},
      {'value': _resHours, 'label': 'Hours'},
      {'value': _resMins, 'label': 'Mins'},
      {'value': _resSecs, 'label': 'Secs'},
    ];

    return Container(
      key: ValueKey('result_${_resYears}_${_resMonths}_${_resDays}_${_resHours}_${_resMins}_${_resSecs}_$isNeg'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor.withValues(alpha: 0.08), accentColor.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          if (isNeg)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 14),
                    const SizedBox(width: 4),
                    Text('Negative Result', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600, fontSize: 11)),
                  ],
                ),
              ),
            ),
          Row(
            children: List.generate(6, (i) {
              final val = results[i]['value'] as int;
              final lab = results[i]['label'] as String;
              final displayVal = (i == 0 && isNeg) ? '-$val' : '$val';
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 3, right: i == 5 ? 0 : 3),
                  child: Column(
                    children: [
                      Text(
                        displayVal,
                        style: TextStyle(
                          fontSize: val > 0 ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          color: val > 0 ? accentColor : colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lab,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 0.3),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
