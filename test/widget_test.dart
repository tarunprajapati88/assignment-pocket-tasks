import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_tasks/models/task.dart';
import 'package:pocket_tasks/provides/task_provider.dart';

void main() {
  group('TaskProvider Search and Filter Tests', () {
    late TaskProvider provider;

    setUp(() {
      provider = TaskProvider();
      // Add test tasks
      provider.tasks.addAll([
        Task(title: 'Buy groceries', done: false, createdAt: DateTime.now()),
        Task(title: 'Complete Flutter project', done: true, createdAt: DateTime.now()),
        Task(title: 'Buy new laptop', done: false, createdAt: DateTime.now()),
        Task(title: 'Read book', done: true, createdAt: DateTime.now()),
        Task(title: 'Exercise', done: false, createdAt: DateTime.now()),
      ]);
    });

    test('should filter all tasks correctly', () {
      provider.setFilter(TaskFilter.all);
      expect(provider.filteredTasks.length, 5);
    });

    test('should filter active tasks correctly', () {
      provider.setFilter(TaskFilter.active);
      final activeTasks = provider.filteredTasks;
      expect(activeTasks.length, 3);
      expect(activeTasks.every((task) => !task.done), true);
    });

    test('should filter done tasks correctly', () {
      provider.setFilter(TaskFilter.done);
      final doneTasks = provider.filteredTasks;
      expect(doneTasks.length, 2);
      expect(doneTasks.every((task) => task.done), true);
    });

    test('should search tasks by title correctly', () async {
      provider.updateSearchQuery('buy');
      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 350));
      expect(provider.filteredTasks.length, 2);
      expect(provider.filteredTasks.every((task) =>
          task.title.toLowerCase().contains('buy')), true);
    });

    test('should combine search and filter correctly', () async {
      provider.setFilter(TaskFilter.active);
      provider.updateSearchQuery('buy');
      await Future.delayed(const Duration(milliseconds: 350));

      final filtered = provider.filteredTasks;
      expect(filtered.length, 2);
      expect(filtered.every((task) => !task.done), true);
      expect(filtered.every((task) =>
          task.title.toLowerCase().contains('buy')), true);
    });

    test('should calculate completion progress correctly', () {
      expect(provider.completionProgress, 0.4); // 2 done out of 5 total
    });
  });
}
