import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/task.dart';
import '../services/task_storage.dart';

enum TaskFilter { all, active, done }

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;
  Timer? _debounceTimer;

  List<Task> get tasks => _tasks;
  String get searchQuery => _searchQuery;
  TaskFilter get currentFilter => _currentFilter;

  List<Task> get filteredTasks {
    List<Task> filtered = _tasks.where((task) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        if (!task.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Apply status filter
      switch (_currentFilter) {
        case TaskFilter.active:
          return !task.done;
        case TaskFilter.done:
          return task.done;
        case TaskFilter.all:
        default:
          return true;
      }
    }).toList();

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.done).length;
  double get completionProgress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  Future<void> loadTasks() async {
    _tasks = await TaskStorage.loadTasks();
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    final newTask = Task(
      title: title.trim(),
      done: false,
      createdAt: DateTime.now(),
    );

    _tasks.add(newTask);
    await _saveTasks();
    notifyListeners();
  }

  // Add this to your TaskProvider class
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

// Update _saveTasks method
  Future<void> _saveTasks() async {
    try {
      await TaskStorage.saveTasks(_tasks);
    } catch (e) {
      debugPrint('Failed to save tasks: $e');
      if (_context != null && _context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: const Text('Failed to save tasks. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> toggleTask(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(done: !_tasks[taskIndex].done);
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
    notifyListeners();
  }

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  Future<void> restoreTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      notifyListeners();
    });
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }


  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
