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

class _TaskTileState extends State<TaskTile> {
  final tasksBox = Hive.box('tasks');
  final completeTasksBox = Hive.box('done_tasks');

  void toggleTaskStatus() async{
    // تحديد الصندوق المصدر والصندوق الهدف بناءً على حالة المهمة الحالية
    final sourceBox = widget.done! ? completeTasksBox : tasksBox;
    final destinationBox = widget.done! ? tasksBox : completeTasksBox;
    
    // الحصول على قائمة المهام من الصندوقين
    final List sourceList = List.from(sourceBox.get('myTasks', defaultValue: []));
    final List destinationList = List.from(destinationBox.get('myTasks', defaultValue: []));

    // التأكد من أن الفهرس (index) صالح قبل المتابعة
    if (widget.taskIndex < sourceList.length) {
      // 1. إزالة المهمة من القائمة المصدر وتخزينها في متغير
      final taskToMove = sourceList.removeAt(widget.taskIndex);

      // 2. إضافة المهمة التي تم إزالتها إلى القائمة الهدف
      destinationList.add(taskToMove);

      // 3. حفظ القائمتين المحدثتين مرة أخرى في صناديق Hive
      sourceBox.put('myTasks', sourceList);
      destinationBox.put('myTasks', destinationList);

      setState(() {
        widget.done! ? widget.done = false : widget.done = true;
      });

      await Future.delayed(Duration(seconds: 1));

      // 4. استدعاء الدالة لتحديث الواجهة في الصفحة الرئيسية
      widget.onStatusChanged();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
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
        subtitle: widget.description != null && widget.description!.isNotEmpty
            ? Text(
                widget.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  decoration: widget.done! ? TextDecoration.lineThrough : null,
                ),
              )
            : null,
        leading: IconButton(
          icon: Icon(widget.done! ? Icons.done_outline : Icons.square_outlined),
          onPressed: () {
            setState(() {
              toggleTaskStatus();
            });
          },
        ),
        trailing: widget.date != null ? Text(widget.date!) : null,
      ),
    );
  }
}
