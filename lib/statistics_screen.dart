import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'components/progress_chart.dart';

class StatisticsScreen extends StatefulWidget {
  final String habitId;
  final String habitName;

  const StatisticsScreen({
    super.key,
    required this.habitId,
    required this.habitName,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _firebaseService.getHabitHistory(
        widget.habitId,
        _selectedDate.year,
        _selectedDate.month,
      );

      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки статистики: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + delta,
        1,
      );
    });
    _loadStats();
  }

  String _getMonthName(int month) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final completions = (_stats['completions'] as Map<int, bool>?) ?? {};
    final passedDays = _stats['passedDays'] as int? ?? 0;
    final completedDays = _stats['completedDays'] as int? ?? 0;
    final longestStreak = _stats['longestStreak'] as int? ?? 0;
    final year = _stats['year'] as int? ?? DateTime.now().year;
    final month = _stats['month'] as int? ?? DateTime.now().month;
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика', style: TextStyle(fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                widget.habitName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            _buildMonthCalendar(completions, year, month, passedDays),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Самая длинная серия',
                    value: '$longestStreak дней',
                    icon: Icons.timeline,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildStatCard(
                    title: 'Текущий прогресс',
                    value: '$completedDays/$passedDays',
                    icon: Icons.calendar_today,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Прогресс выполнения',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ProgressChart(
                    completed: completedDays,
                    total: passedDays,
                    size: 120,
                    showText: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    passedDays > 0
                        ? '${(completedDays / passedDays * 100).toStringAsFixed(1)}%'
                        : '0%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ExpansionTile(
              title: const Text(
                'Подробная информация',
                style: TextStyle(fontSize: 14),
              ),
              initiallyExpanded: false,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID привычки: ${widget.habitId}'),
                      const SizedBox(height: 8),
                      Text('Месяц: ${_getMonthName(month)} $year'),
                      const SizedBox(height: 8),
                      Text('Всего дней: $passedDays'),
                      const SizedBox(height: 8),
                      Text('Дней выполнено: $completedDays'),
                      const SizedBox(height: 8),
                      Text(
                        'Процент выполнения: ${passedDays > 0 ? (completedDays / passedDays * 100).toStringAsFixed(1) : 0}%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCalendar(
    Map<int, bool> completions,
    int year,
    int month,
    int passedDays,
  ) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = firstDay.weekday;
    final startOffset = firstWeekday - 1;
    final today = DateTime.now();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Управление месяцем
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                  iconSize: 20,
                ),
                Text(
                  '${_getMonthName(month)} $year',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                  iconSize: 20,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Дни недели
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WeekDayLabel('Пн', isWeekend: false),
                _WeekDayLabel('Вт', isWeekend: false),
                _WeekDayLabel('Ср', isWeekend: false),
                _WeekDayLabel('Чт', isWeekend: false),
                _WeekDayLabel('Пт', isWeekend: false),
                _WeekDayLabel('Сб', isWeekend: true),
                _WeekDayLabel('Вс', isWeekend: true),
              ],
            ),

            const SizedBox(height: 8),

            // Сетка дней месяца
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 1.2,
              ),
              itemCount: startOffset + daysInMonth,
              itemBuilder: (context, index) {
                if (index < startOffset) {
                  return const SizedBox.shrink();
                }

                final day = index - startOffset + 1;
                final isCompleted = completions[day] ?? false;
                final isToday =
                    today.year == year &&
                    today.month == month &&
                    day == today.day;
                final isFuture = day > passedDays;
                final isPast = day <= passedDays && !isToday;

                return _DayCell(
                  day: day,
                  isCompleted: isCompleted,
                  isToday: isToday,
                  isFuture: isFuture,
                  isPast: isPast,
                );
              },
            ),

            const SizedBox(height: 12),

            // Легенда
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Выполнено'),
                _buildLegendItem(Colors.red, 'Не выполнено'),
                _buildLegendItem(Colors.grey[300]!, 'Будущее'),
                _buildLegendItem(Colors.blue, 'Сегодня'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _WeekDayLabel extends StatelessWidget {
  final String label;
  final bool isWeekend;

  const _WeekDayLabel(this.label, {required this.isWeekend});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isWeekend ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isToday;
  final bool isFuture;
  final bool isPast;

  const _DayCell({
    required this.day,
    required this.isCompleted,
    required this.isToday,
    required this.isFuture,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.transparent;
    Color textColor = Colors.black;
    double fontSize = 12;

    if (isToday) {
      backgroundColor = Colors.blue.withOpacity(0.2);
      textColor = Colors.blue;
      fontSize = 13;
    } else if (isFuture) {
      backgroundColor = Colors.grey[100]!;
      textColor = Colors.grey[400]!;
    } else if (isCompleted) {
      backgroundColor = Colors.green.withOpacity(0.3);
      textColor = Colors.green;
    } else if (isPast) {
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red.withOpacity(0.7);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: isToday
            ? Border.all(color: Colors.blue, width: 1.5)
            : Border.all(color: Colors.grey[200]!, width: 0.5),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
