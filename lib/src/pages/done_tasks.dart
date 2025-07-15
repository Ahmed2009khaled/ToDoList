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

    // --- ADD THIS SORTING LOGIC ---
    // This sorts the list based on the 'date' string.
    // It places tasks with no date at the end of the list.
    refreshedTasks.sort((a, b) {
      final dateA = a['date'] as String? ?? '';
      final dateB = b['date'] as String? ?? '';

      if (dateA.isEmpty) return 1; // Pushes tasks without a date to the end
      if (dateB.isEmpty) return -1; // Keeps tasks with a date at the front

      return dateA.compareTo(dateB); // Sorts chronologically
    });
    // --- END OF SORTING LOGIC ---

    setState(() {
      doneTasks = refreshedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Completed Tasks',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('home');
          },
          icon: Icon(Icons.list_alt_sharp),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: doneTasks.isNotEmpty
            ? ListView.builder(
                itemCount: doneTasks.length,
                itemBuilder: (context, i) {
                  final task = doneTasks[i];
                  return TaskTile(
                    name: task['name'],
                    description: task['descr'],
                    date: task['date'],
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditTask(task: task, taskIndex: i),
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
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Completed tasks will appear here",
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
