import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A page for adding a new task to the Hive database.
class AddTask extends StatefulWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  AddTask({super.key});

  @override
  AddTaskState createState() => AddTaskState();
}

class AddTaskState extends State<AddTask> {

  GlobalKey<FormState> titleState = GlobalKey();

  final Box tasksBox = Hive.box('Tasks');

  @override
  void dispose() {
    widget.titleController.dispose();
    widget.descriptionController.dispose();
    widget.dateController.dispose();
    super.dispose();
  }

  /// Saves a new task to Hive and closes the page.
  void saveTask() {
    final data = tasksBox.get('myTasks', defaultValue: []);
    List<Map<String, dynamic>> updatedList = List.from(data).map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();

    updatedList.add({
      'name': widget.titleController.text,
      'descr': widget.descriptionController.text,
      'date': widget.dateController.text,
    });

    tasksBox.put('myTasks', updatedList);
    Navigator.of(context).pop();
  }

  /// Builds the add task form UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "New Task",
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
                      controller: widget.titleController,
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
                        if (value!.isEmpty){
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
                    controller: widget.descriptionController,
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
                    controller: widget.dateController,
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
                              widget.dateController.text =
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
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
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
                    onPressed: (){
                      if (titleState.currentState!.validate()){
                        saveTask();
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
