import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provides/task_provider.dart';
import '../widgets/add_task_form.dart';
import '../widgets/task_item.dart';
import '../widgets/circular_progress_painter.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaskProvider>();
      provider.setContext(context);
      provider.loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUndoSnackBar(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: onUndo,
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
              const Color(0xFF334155),
            ]
                : [
              const Color(0xFFF1F5F9),
              const Color(0xFFE2E8F0),
              const Color(0xFFCBD5E1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCompactAppBar(context, isDark),
              _buildAddTaskSection(context),
              _buildSearchAndFilterRow(context),
              Expanded(child: _buildTaskList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PocketTasks',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Consumer<TaskProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      '${provider.completedTasks}/${provider.totalTasks} tasks completed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF64748B),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Consumer<TaskProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircularProgressWidget(
                  progress: provider.completionProgress,
                  size: 40,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: AddTaskForm(
        onAddTask: (title) => context.read<TaskProvider>().addTask(title),
      ),
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<TaskProvider>().updateSearchQuery('');
                },
              )
                  : null,
            ),
            onChanged: (query) =>
                context.read<TaskProvider>().updateSearchQuery(query),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          Consumer<TaskProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TaskFilter.values.map((filter) {
                    final isSelected = provider.currentFilter == filter;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(
                          _getFilterLabel(filter),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : const Color(0xFF64748B)),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => provider.setFilter(filter),
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        selectedColor: const Color(0xFF6366F1),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.filteredTasks;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.task_alt,
                    size: 64,
                    color: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  provider.searchQuery.isNotEmpty
                      ? 'No tasks found'
                      : 'No tasks yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'Add your first task to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20), // Add bottom padding
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: TaskItem(
                  task: task,
                  onToggle: () {
                    final wasCompleted = task.done;
                    provider.toggleTask(task.id);
                    _showUndoSnackBar(
                      wasCompleted ? 'Task marked as active' : 'Task completed',
                          () => provider.toggleTask(task.id),
                    );
                  },
                  onDelete: () {
                    provider.deleteTask(task.id);
                    _showUndoSnackBar(
                      'Task deleted',
                          () => provider.restoreTask(task),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.active:
        return 'Active';
      case TaskFilter.done:
        return 'Done';
    }
  }
}
