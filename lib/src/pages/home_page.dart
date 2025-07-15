import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list_app/src/materials/task_tile.dart';
import 'package:to_do_list_app/src/pages/edit_task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Box tasksBox = Hive.box('Tasks');
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  /// Loads tasks from Hive and updates the state
  void _refreshTasks() {
    final data = tasksBox.get('myTasks', defaultValue: []);
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
      tasks = refreshedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'My Tasks ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('done_tasks');
          },
          icon: Icon(Icons.task_alt_sharp),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: tasks.isNotEmpty
            ? ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
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
                    done: false,
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
                      "No tasks yet",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Tap the + Button to add new tasks",
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).pushNamed('add_task').then((_) => _refreshTasks());
        },
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
