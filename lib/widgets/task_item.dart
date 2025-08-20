import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem>
    with SingleTickerProviderStateMixin {
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
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dismissible(
        key: Key(widget.task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                'Delete',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        onDismissed: (_) => widget.onDelete(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.task.done
                  ? (isDark
                  ? [
                const Color(0xFF1E293B).withOpacity(0.7),
                const Color(0xFF334155).withOpacity(0.7),
              ]
                  : [
                const Color(0xFFF1F5F9),
                const Color(0xFFE2E8F0),
              ])
                  : (isDark
                  ? [
                const Color(0xFF1E293B),
                const Color(0xFF334155),
              ]
                  : [
                Colors.white,
                const Color(0xFFF8FAFC),
              ]),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.task.done
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : (isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0)),
              width: widget.task.done ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: GestureDetector(
              onTap: _onTap,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.task.done
                      ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  )
                      : null,
                  border: Border.all(
                    color: widget.task.done
                        ? const Color(0xFF10B981)
                        : (isDark
                        ? Colors.white.withOpacity(0.5)
                        : const Color(0xFF94A3B8)),
                    width: 2,
                  ),
                ),
                child: widget.task.done
                    ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
            title: Text(
              widget.task.title,
              style: theme.textTheme.titleMedium?.copyWith(
                decoration: widget.task.done ? TextDecoration.lineThrough : null,
                color: widget.task.done
                    ? (isDark
                    ? Colors.white.withOpacity(0.5)
                    : const Color(0xFF64748B))
                    : (isDark ? Colors.white : const Color(0xFF1E293B)),
                fontWeight: widget.task.done ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            subtitle: Text(
              _formatDate(widget.task.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF64748B),
              ),
            ),
            trailing: widget.task.done
                ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Done',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : Icon(
              Icons.radio_button_unchecked,
              color: isDark
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFF94A3B8),
            ),
            onTap: _onTap,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
