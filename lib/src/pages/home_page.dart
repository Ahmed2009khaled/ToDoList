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
  final Box tasksBox = Hive.box('tasks');
  List<Map<String, dynamic>> tasks = [];

  final Box settings = Hive.box('settings');

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

  refreshedTasks.sort((a, b) {
    final dateA = a['date'] as String? ?? '';
    final dateB = b['date'] as String? ?? '';
    final timeA = a['time'] as String? ?? '';
    final timeB = b['time'] as String? ?? '';

    // 1. المهام بدون تاريخ تكون في النهاية
    if (dateA.isEmpty && dateB.isNotEmpty) return 1;
    if (dateA.isNotEmpty && dateB.isEmpty) return -1;

    // 2. إذا كانت التواريخ مختلفة، رتب حسب التاريخ
    if (dateA.isNotEmpty && dateB.isNotEmpty) {
      final dateComparison = dateA.compareTo(dateB);
      if (dateComparison != 0) {
        return dateComparison;
      }
      
      // 3. إذا كانت التواريخ متساوية، رتب حسب الوقت
      // المهمة بدون وقت تأتي بعد المهمة التي لها وقت في نفس اليوم
      if (timeA.isEmpty && timeB.isNotEmpty) return 1;
      if (timeA.isNotEmpty && timeB.isEmpty) return -1;
      
      final timeComparison = timeA.compareTo(timeB);
      if (timeComparison != 0) {
        return timeComparison;
      }
    }

    // 4. كحل أخير، رتب حسب وقت الإنشاء
    final createdAtA = a['createdAt'] as String? ?? '';
    final createdAtB = b['createdAt'] as String? ?? '';
    return createdAtA.compareTo(createdAtB);
  });

    setState(() {
      tasks = refreshedTasks;
      tasksBox.put('myTasks', tasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/done_tasks');
          },
          icon: Icon(Icons.task_alt_sharp),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
            icon: Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: tasks.isNotEmpty
            ? ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  return TaskTile(
                    key: ValueKey(task),
                    name: task['name'],
                    description: task['descr'],
                    date: task['date'],
                    time: task['time'],
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => EditTask(
                                task: task,
                                taskIndex: i,
                                done: false,
                              ),
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
                      ),
                    ),
                    Text(
                      "Tap the + Button to add new tasks",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).pushNamed('/add_task').then((_) => _refreshTasks());
        },
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
