import 'package:flutter/material.dart';

class AddTaskForm extends StatefulWidget {
  final Function(String) onAddTask;

  const AddTaskForm({super.key, required this.onAddTask});

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  String? _errorText;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _addTask() {
    final title = _controller.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorText = 'Please enter a task title';
      });
      return;
    }

    // Animate button press
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    widget.onAddTask(title);
    _controller.clear();
    setState(() {
      _errorText = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            const Color(0xFF1E293B),
            const Color(0xFF334155),
          ]
              : [
            Colors.white,
            const Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Task',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    errorText: _errorText,
                    prefixIcon: Icon(
                      Icons.add_task,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onSubmitted: (_) => _addTask(),
                  onChanged: (value) {
                    if (_errorText != null && value.trim().isNotEmpty) {
                      setState(() {
                        _errorText = null;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
