import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getHabits() async {
    try {
      final snapshot = await _firestore.collection('habits').get();
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data(), 'completed': false};
      }).toList();
    } catch (e) {
      print('Ошибка загрузки привычек: $e');
      return [];
    }
  }

  Future<void> completeHabit(String habitId) async {
    try {
      await _firestore.collection('completions').add({
        'habitId': habitId,
        'completedAt': DateTime.now(),
        'date': DateTime.now().toIso8601String().split('T')[0],
      });
    } catch (e) {
      print('Ошибка отметки привычки: $e');
    }
  }

  Future<void> uncompleteHabit(String habitId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final snapshot = await _firestore
          .collection('completions')
          .where('habitId', isEqualTo: habitId)
          .where('date', isEqualTo: today)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.last.reference.delete();
      }
    } catch (e) {
      print('Ошибка отмены отметки: $e');
    }
  }

  Future<bool> isHabitCompletedToday(String habitId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final snapshot = await _firestore
          .collection('completions')
          .where('habitId', isEqualTo: habitId)
          .where('date', isEqualTo: today)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Ошибка проверки статуса: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getHabitHistory(
    String habitId,
    int year,
    int month,
  ) async {
    print('=== НАЧАЛО getHabitHistory ===');
    print('Параметры: habitId=$habitId, year=$year, month=$month');

    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];

      print('Период: $startDateStr - $endDateStr');

      final snapshot = await _firestore
          .collection('completions')
          .where('habitId', isEqualTo: habitId)
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();

      print('Найдено документов: ${snapshot.docs.length}');

      final completions = <int, bool>{};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final dateStr = data['date'] as String?;

        if (dateStr != null) {
          final day = int.parse(dateStr.split('-')[2]);
          completions[day] = true;
          print('День выполнения: $day');
        }
      }

      final today = DateTime.now();
      final passedDays = today.year == year && today.month == month
          ? today.day
          : DateTime(year, month + 1, 0).day;

      final completedDays = completions.length;
      final longestStreak = _calculateLongestStreak(completions, passedDays);

      print('Результат:');
      print('- Прошедших дней: $passedDays');
      print('- Выполнено дней: $completedDays');
      print('- Самая длинная серия: $longestStreak');
      print('- Выполненные дни: ${completions.keys.toList()}');
      print('=== КОНЕЦ getHabitHistory ===');

      // ИСПРАВЛЕНИЕ: Явное преобразование типа
      return {
        'completions': Map<int, bool>.from(completions),
        'passedDays': passedDays,
        'completedDays': completedDays,
        'longestStreak': longestStreak,
        'year': year,
        'month': month,
      };
    } catch (e) {
      print('=== ОШИБКА В getHabitHistory ===');
      print('Тип ошибки: ${e.runtimeType}');
      print('Сообщение: $e');
      print('=== КОНЕЦ ОШИБКИ ===');

      // ИСПРАВЛЕНИЕ: Тут тоже
      return {
        'completions': Map<int, bool>.from({}),
        'passedDays': 0,
        'completedDays': 0,
        'longestStreak': 0,
        'year': year,
        'month': month,
      };
    }
  }

  int _calculateLongestStreak(Map<int, bool> completions, int passedDays) {
    int longest = 0;
    int current = 0;

    for (int day = 1; day <= passedDays; day++) {
      if (completions[day] == true) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }

    return longest;
  }
}
