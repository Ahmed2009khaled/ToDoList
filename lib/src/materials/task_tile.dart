import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A customizable task tile widget for displaying task details with completion toggle.
// ignore: must_be_immutable
class TaskTile extends StatefulWidget {
  final String? name;
  final String? description;
  final String? date;
  final VoidCallback? onTap;
  bool? done;
  final int taskIndex;
  final VoidCallback onStatusChanged;

  TaskTile({
    super.key,
    required this.name,
    this.description,
    this.date,
    this.onTap,
    this.done,
    required this.taskIndex,
    required this.onStatusChanged,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  final tasksBox = Hive.box('tasks');
  final completeTasksBox = Hive.box('done_tasks');

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 4. نكتب "السيناريو" للحركة والاختفاء
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0.0),
    ).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleTaskStatus() async {
    // تحديد الصندوق المصدر والصندوق الهدف بناءً على حالة المهمة الحالية
    final sourceBox = widget.done! ? completeTasksBox : tasksBox;
    final destinationBox = widget.done! ? tasksBox : completeTasksBox;

    // الحصول على قائمة المهام من الصندوقين
    final List sourceList = List.from(
      sourceBox.get('myTasks', defaultValue: []),
    );
    final List destinationList = List.from(
      destinationBox.get('myTasks', defaultValue: []),
    );

    // التأكد من أن الفهرس (index) صالح قبل المتابعة
    if (widget.taskIndex < sourceList.length) {
      // 1. إزالة المهمة من القائمة المصدر وتخزينها في متغير
      final taskToMove = sourceList.elementAt(widget.taskIndex);
      sourceList.removeAt(widget.taskIndex);

    if (!widget.done!) {
      // أضف وقت الإكمال الآن
      taskToMove['completedAt'] = DateTime.now().toIso8601String();
    } else {
        
      taskToMove['createdAt'] = DateTime.now().toIso8601String(); 
    }

      // 2. إضافة المهمة التي تم إزالتها إلى القائمة الهدف
      destinationList.add(taskToMove);

      // 3. حفظ القائمتين المحدثتين مرة أخرى في صناديق Hive
      sourceBox.put('myTasks', sourceList);
      destinationBox.put('myTasks', destinationList);

      setState(() {
        widget.done! ? widget.done = false : widget.done = true;
      });

      await _controller.forward();

      setState(() {});
      // 4. استدعاء الدالة لتحديث الواجهة في الصفحة الرئيسية
      widget.onStatusChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          color: Colors.white,
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            onTap: widget.onTap,
            iconColor: Colors.grey,
            textColor: Colors.black,
            title: Text(
              widget.name ?? '',
              style: TextStyle(
                decoration: widget.done! ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle:
                widget.description != null && widget.description!.isNotEmpty
                ? Text(
                    widget.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      decoration: widget.done!
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  )
                : null,
            leading: IconButton(
              icon: Icon(
                widget.done! ? Icons.done_outline : Icons.square_outlined,
              ),
              onPressed: () {
                toggleTaskStatus();
              },
            ),
            trailing: widget.date != null ? Text(widget.date!) : null,
          ),
        ),
      ),
    );
  }
}
