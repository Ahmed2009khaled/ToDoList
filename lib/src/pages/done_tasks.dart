import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list_app/src/materials/task_tile.dart';
import 'package:to_do_list_app/src/pages/edit_task.dart';

class DoneTasksPage extends StatefulWidget {
  const DoneTasksPage({super.key});

  @override
  State<DoneTasksPage> createState() => DoneTasksPageState();
}

class DoneTasksPageState extends State<DoneTasksPage> {
  final Box doneTasksBox = Hive.box('done_tasks');
  List<Map<String, dynamic>> doneTasks = [];

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  /// Loads tasks from Hive and updates the state
  void _refreshTasks() {
    final data = doneTasksBox.get('myTasks', defaultValue: []);
    final refreshedTasks = List.from(data).map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();

    refreshedTasks.sort((a, b) {
      // تأكد من وجود الحقل لتجنب الأخطاء
      final completedAtA = a['completedAt'] as String? ?? '';
      final completedAtB = b['completedAt'] as String? ?? '';

      // b.compareTo(a) للترتيب التنازلي (الأحدث في الأعلى)
      return completedAtA.compareTo(completedAtB);
    });

    setState(() {
      doneTasks = refreshedTasks;
      doneTasksBox.put('myTasks', doneTasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Completed Tasks',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
          icon: Icon(Icons.list_alt_sharp),
        ),
        actions: [
          IconButton(icon: Icon(Icons.cleaning_services_outlined), onPressed: () {
            setState(() {
              doneTasksBox.clear();
              doneTasks.clear();
              _refreshTasks();
            });
          },)
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: doneTasks.isNotEmpty
            ? ListView.builder(
                itemCount: doneTasks.length,
                itemBuilder: (context, i) {
                  final task = doneTasks[i];
                  return TaskTile(
                    key: ValueKey(task),
                    name: task['name'],
                    description: task['descr'],
                    date: task['date'],
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => EditTask(
                                task: task,
                                taskIndex: i,
                                done: true,
                              ),
                            ),
                          )
                          .then((_) => _refreshTasks());
                    },
                    done: true,
                    taskIndex: i,
                    onStatusChanged: _refreshTasks,
                  );
                },
              )
            : Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Text(
                      "No completed tasks yet",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Completed tasks will appear here",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
