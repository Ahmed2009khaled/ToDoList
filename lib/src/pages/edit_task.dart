import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A page for adding a new task to the Hive database.
class EditTask extends StatefulWidget {
  final bool? done;

  final Map<String, dynamic> task; // لاستقبال بيانات المهمة
  final int taskIndex; // لاستقبال موقع المهمة

  const EditTask({
    super.key,
    required this.task,
    required this.taskIndex,
    required this.done,
  });

  @override
  EditTaskState createState() => EditTaskState();
}

class EditTaskState extends State<EditTask> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;

  GlobalKey<FormState> titleState = GlobalKey();

  late final Box tasksBox;

  @override
  void initState() {
    super.initState();
    tasksBox = widget.done! ? Hive.box('done_tasks') : Hive.box('Tasks');

    titleController = TextEditingController(text: widget.task['name']);
    descriptionController = TextEditingController(text: widget.task['descr']);
    dateController = TextEditingController(text: widget.task['date']);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void updateTask() {
    final data = tasksBox.get('myTasks', defaultValue: []);
    List<Map<String, dynamic>> updatedList = List.from(data).map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();

    updatedList[widget.taskIndex] = {
      'name': titleController.text,
      'descr': descriptionController.text,
      'date': dateController.text,
    };

    tasksBox.put('myTasks', updatedList);
    Navigator.of(context).pop();
  }

  void deleteTask() {
    final data = tasksBox.get('myTasks', defaultValue: []);
    List<Map<String, dynamic>> updatedList = List.from(data).map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();

    updatedList.removeAt(widget.taskIndex);

    tasksBox.put('myTasks', updatedList);
    Navigator.of(context).pop();
  }

  /// Builds the add task form UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Task",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    " Task Title",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: titleState,
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      controller: titleController,
                      decoration: InputDecoration(
                        fillColor: Colors.lightBlueAccent[1],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Grocery Shopping",
                        filled: true,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Title Cant Be Empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    " Task Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      fillColor: Colors.lightBlueAccent[1],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Add Any Details",
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    " Due Date",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      fillColor: Colors.lightBlueAccent[1],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range_outlined),
                        onPressed: () async {
                          DateTime? dateTimePicker =
                              await showOmniDateTimePicker(
                                context: context,
                                type: OmniDateTimePickerType.date,
                              );
                          if (dateTimePicker != null) {
                            setState(() {
                              dateController.text =
                                  "${dateTimePicker.year}-${dateTimePicker.month.toString().padLeft(2, '0')}-${dateTimePicker.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                      ),
                      hintText: "Select Date",
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    color: Colors.red,

                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onPressed: () {
                      deleteTask();
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 25),
                Expanded(
                  child: MaterialButton(
                    color: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onPressed: () {
                      if (titleState.currentState!.validate()) {
                        updateTask();
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
