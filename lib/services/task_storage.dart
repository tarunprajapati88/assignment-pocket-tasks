import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorage {
  static const String _storageKey = 'pocket_tasks_v1';

  static Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_storageKey);

      if (tasksJson == null) return [];

      final List<dynamic> tasksList = jsonDecode(tasksJson);
      return tasksList.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
      await prefs.setString(_storageKey, tasksJson);
    } catch (e) {
      debugPrint('Failed to save tasks: $e');
    }
  }

}
