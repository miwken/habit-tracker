import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_config.dart';
import 'firebase_service.dart';
import 'statistics_screen.dart';
import 'components/progress_chart.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'design_system/cards/habit_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey']!,
      authDomain: firebaseConfig['authDomain']!,
      projectId: firebaseConfig['projectId']!,
      storageBucket: firebaseConfig['storageBucket']!,
      messagingSenderId: firebaseConfig['messagingSenderId']!,
      appId: firebaseConfig['appId']!,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Трекер Привычек',
      theme: AppTheme.lightTheme,
      home: const HabitsScreen(),
    );
  }
}

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> habits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      isLoading = true;
    });

    final loadedHabits = await _firebaseService.getHabits();

    for (var habit in loadedHabits) {
      final isCompleted = await _firebaseService.isHabitCompletedToday(
        habit['id'],
      );
      habit['completed'] = isCompleted;
    }

    setState(() {
      habits = loadedHabits;
      isLoading = false;
    });
  }

  Future<void> _markHabit(int index, bool isCompleted) async {
    final habit = habits[index];
    final habitId = habit['id'];

    if (isCompleted) {
      if (!(habit['completed'] == true)) {
        await _firebaseService.completeHabit(habitId);
      }
    } else {
      if (habit['completed'] == true) {
        await _firebaseService.uncompleteHabit(habitId);
      }
    }

    setState(() {
      habits[index]['completed'] = isCompleted;
    });

    await _loadHabits();
  }

  int get completedCount {
    return habits.where((habit) => habit['completed'] == true).length;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Мои привычки',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                // Текстовый счетчик
                Text(
                  'Выполнено: $completedCount/${habits.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),

                // Круговая диаграмма
                if (habits.isNotEmpty)
                  ProgressChart(
                    completed: completedCount,
                    total: habits.length,
                    size: 36,
                    showText: true,
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: AppColors.surfaceLight,
              child: Icon(Icons.person, size: 18, color: AppColors.textPrimary),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHabits,
        child: ListView.builder(
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: HabitCard(
                title: habit['name'] ?? 'Без названия',
                isCompleted: habit['completed'] == true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatisticsScreen(
                        habitId: habit['id'],
                        habitName: habit['name'] ?? 'Без названия',
                      ),
                    ),
                  );
                },
                onCheck: () => _markHabit(index, true),
                onCancel: () => _markHabit(index, false),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Добавление привычки (скоро!)'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
