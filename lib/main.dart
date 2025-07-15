import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list_app/src/pages/add_task.dart';
import 'package:to_do_list_app/src/pages/done_tasks.dart';
// import 'package:to_do_list_app/src/pages/edit_task.dart';
import 'package:to_do_list_app/src/pages/home_page.dart';

/// Entry point of the To Do List application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tasks');
  await Hive.openBox('done_tasks');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        'add_task': (context) => AddTask(),
        'done_tasks': (context) => DoneTasksPage()
      },
    );
  }
}