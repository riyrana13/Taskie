// add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:taskie/models/task.dart';
import 'package:taskie/repositories/task_repository.dart';
import 'package:taskie/util_files/multiple_image_input.dart';

// ignore: must_be_immutable
class AddTaskScreen extends StatefulWidget {
  AddTaskScreen({Key? key, this.taskId}) : super(key: key);
  int? taskId;
  static const String routeName = '/add_task';

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  Task? task;
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  // bool _notificationEnabled = false;
  List<String>? _photos;

  @override
  void initState() {
    super.initState();
    _fetchTask();
  }

  Future<void> _fetchTask() async {
    if (widget.taskId != null) {
      final taskData = await TaskRepository().getTask(widget.taskId!);

      setState(() {
        task = taskData;
        _taskController.text = taskData.task;
        _descriptionController.text = taskData.description;
        _dateController.text = taskData.date;
        _timeController.text = taskData.time;
        // _notificationEnabled = taskData.notificationEnabled;
        _photos = taskData.photos;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: task != null
          ? DateFormat('dd-MM-yyyy').parse(task!.date)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime;

    if (task != null) {
      final timeFormat = DateFormat('hh:mm a');
      final dateTime = timeFormat.parse(task!.time);
      initialTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } else {
      initialTime = TimeOfDay.now();
    }
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(
        DateTime(
            now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
      );

      setState(() {
        _timeController.text = formattedTime;
      });
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Image.asset(
            'assets/bell.png',
            fit: BoxFit.fill,
          ),
        ),
        title: widget.taskId != null
            ? const Text('Edit Task')
            : const Text('Add Task'),
      ),
      body: widget.taskId != null && task == null
          ? Container(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _taskController,
                        decoration: const InputDecoration(
                          labelText: 'Task',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter task';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true, // Makes the field read-only
                        onTap: () =>
                            _selectDate(context), // Open date picker on tap
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true, // Makes the field read-only
                        onTap: () =>
                            _selectTime(context), // Open time picker on tap
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a time';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      MultipleImageInput(
                          images: _photos,
                          onPickImages: (images) {
                            setState(() {
                              _photos = images
                                  .map((image) => image.path.toString())
                                  .toList();
                            });
                          }),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 60,
          padding: EdgeInsets.all(8),
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
              Colors.purple[100]!,
            )),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _addTask();
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addTask() async {
    final task = Task(
      task: _taskController.text,
      description: _descriptionController.text,
      date: _dateController.text,
      time: _timeController.text,
      notificationEnabled: false,
      photos: _photos,
    );
    if (widget.taskId == null) {
      await TaskRepository().insertTask(task);
    } else {
      task.id = widget.taskId;
      await TaskRepository().updateTask(task);
    }

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }
}
