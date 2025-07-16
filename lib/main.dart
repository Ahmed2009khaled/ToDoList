import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list_app/src/pages/add_task.dart';
import 'package:to_do_list_app/src/pages/done_tasks.dart';
import 'package:to_do_list_app/src/pages/home_page.dart';
import 'package:to_do_list_app/src/pages/settings.dart';

/// Entry point of the To Do List application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tasks');
  await Hive.openBox('done_tasks');
  await Hive.openBox('settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدم ValueListenableBuilder للاستماع إلى التغييرات في صندوق الإعدادات
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, box, widget) {
        final isDarkMode = box.get('dark_mode', defaultValue: false);

        // تعريف الثيم الفاتح
        final lightTheme = ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black, // لون الأيقونات والنص في AppBar
            elevation: 0,
          ),
          cardColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch().copyWith(surfaceTint: Colors.white),

          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black87),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.grey[200],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );

        // تعريف الثيم الداكن
        final darkTheme = ThemeData(
          
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFF121212), // لون داكن شائع
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardColor: Colors.grey[850],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.grey[800],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );

        return MaterialApp(
          title: 'To Do List',
          // تحديد الثيمات
          theme: lightTheme,
          darkTheme: darkTheme,
          // تحديد الوضع الحالي بناءً على القيمة من Hive
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => HomePage(),
            '/add_task': (context) => AddTask(),
            '/done_tasks': (context) => DoneTasksPage(),
            '/settings': (context) => const Settings(),
          },
        );
      },
    );
  }
}
