import 'package:flutter/material.dart';

/// A customizable task tile widget for displaying task details with completion toggle.
class TaskTile extends StatefulWidget {
  final String? name;
  final String? description;
  final String? date;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.name,
    this.description,
    this.date,
    this.onTap
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool done = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: widget.onTap,
        iconColor: Colors.grey,
        textColor: Colors.black,
        title: Text(
          widget.name ?? '',
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: widget.description != null && widget.description!.isNotEmpty
            ? Text(
                widget.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              )
            : null,
        leading: IconButton(
          icon: Icon(done ? Icons.done_outline : Icons.square_outlined),
          onPressed: () {
            setState(() {
              done = true;
            });
          },
        ),
        trailing: widget.date != null ? Text(widget.date!) : null,
      ),
    );
  }
}
