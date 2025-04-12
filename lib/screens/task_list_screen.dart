// task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:taskie/repositories/task_repository.dart';
import 'package:taskie/util_files/notification_service.dart';

import 'package:taskie/screens/add_task_screen.dart';

import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  static const String routeName = '/task_list';

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    listenNotifications();
    requestNotificationPermission();
    _loadTasks();
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  listenNotifications() {
    LocalNotifications.onClickNotification.stream.listen((event) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TaskListScreen()));
    });
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
        title: const Text('Taskie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, AddTaskScreen.routeName);
              await _loadTasks();
            },
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(
              child: Text('No tasks available'),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final dateFormat = DateFormat("dd-MM-yyyy");
                final timeFormat = DateFormat("hh:mm a");

                DateTime parsedDate = dateFormat.parse(_tasks[index].date);
                DateTime parsedTime = timeFormat.parse(_tasks[index].time);

                DateTime combinedDateTime = DateTime(
                  parsedDate.year,
                  parsedDate.month,
                  parsedDate.day,
                  parsedTime.hour,
                  parsedTime.minute,
                );
                return Card(
                  child: ListTile(
                    title: Text('${_tasks[index].date} ${_tasks[index].time}'),
                    subtitle: Text(_tasks[index].task),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    AddTaskScreen(taskId: _tasks[index].id)));
                            await _loadTasks();
                          },
                        ),
                        Switch(
                          value: _tasks[index].notificationEnabled,
                          onChanged: combinedDateTime.isBefore(DateTime.now())
                              ? null
                              : (bool value) async {
                                  if (value) {
                                    final isScheduled = await LocalNotifications
                                        .showScheduleNotification(
                                      id: _tasks[index].id!,
                                      title: _tasks[index].task,
                                      body: _tasks[index].description,
                                      payload: _tasks[index].task,
                                      dateString: _tasks[index].date,
                                      timeString: _tasks[index].time,
                                    );

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(isScheduled
                                              ? 'Notification Scheduled!!'
                                              : 'Invalid Time!!'),
                                          content: Text(isScheduled
                                              ? 'Reminder set for ${_tasks[index].task} on ${_tasks[index].date} at ${_tasks[index].time}!!'
                                              : 'Cannot schedule Notification as ${_tasks[index].date} at ${_tasks[index].time} is already in the past.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                if (isScheduled) {
                                                  _tasks[index]
                                                          .notificationEnabled =
                                                      true;
                                                  await TaskRepository()
                                                      .updateTask(
                                                          _tasks[index]);
                                                  _loadTasks();
                                                }
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    await LocalNotifications.cancel(
                                        _tasks[index].id!);

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              Text('Notification Canceled!!'),
                                          content: Text(
                                              'Scheduled Notification for ${_tasks[index].date} at ${_tasks[index].time} has been canceled.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                _tasks[index]
                                                        .notificationEnabled =
                                                    false;
                                                await TaskRepository()
                                                    .updateTask(_tasks[index]);
                                                _loadTasks();
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                        ),
                        // if (_tasks[index].notificationEnabled == false)
                        //   IconButton(
                        //       icon: const Icon(Icons.alarm_off_sharp),
                        //       onPressed: () async {
                        //         final isScheduled = await LocalNotifications
                        //             .showScheduleNotification(
                        //                 id: _tasks[index].id!,
                        //                 title: _tasks[index].task,
                        //                 body: _tasks[index].description,
                        //                 payload: _tasks[index].task,
                        //                 dateString: _tasks[index].date,
                        //                 timeString: _tasks[index].time);
                        //         // ignore: use_build_context_synchronously
                        //         showDialog(
                        //           context: context,
                        //           barrierDismissible: false,
                        //           builder: (BuildContext context) {
                        //             return AlertDialog(
                        //               title: Text(isScheduled
                        //                   ? 'Notification Scheduled !!'
                        //                   : 'Invalid Time !!'),
                        //               content: Text(isScheduled
                        //                   ? 'Reminder set for ${_tasks[index].task} on ${_tasks[index].date} at ${_tasks[index].time} !!'
                        //                   : 'Can not schedule Notification as ${_tasks[index].date} at ${_tasks[index].time} is already in the past.'),
                        //               actions: [
                        //                 TextButton(
                        //                   onPressed: () async {
                        //                     if (isScheduled) {
                        //                       _tasks[index]
                        //                           .notificationEnabled = true;
                        //                       await TaskRepository()
                        //                           .updateTask(_tasks[index]);
                        //                       _loadTasks();
                        //                     }
                        //                     Navigator.of(context).pop();
                        //                   },
                        //                   child: const Text('OK'),
                        //                 ),
                        //               ],
                        //             );
                        //           },
                        //         );
                        //       })
                        // else
                        //   IconButton(
                        //       icon: const Icon(Icons.alarm_on),
                        //       onPressed: () async {
                        //         final isScheduled =
                        //             await LocalNotifications.cancel(
                        //                 _tasks[index].id!);
                        //         // ignore: use_build_context_synchronously
                        //         showDialog(
                        //           context: context,
                        //           barrierDismissible: false,
                        //           builder: (BuildContext context) {
                        //             return AlertDialog(
                        //               title: Text('Notification Cancelled !!'),
                        //               content: Text(
                        //                   'Scheduled Notification of ${_tasks[index].date} at ${_tasks[index].time} is cancelled.'),
                        //               actions: [
                        //                 TextButton(
                        //                   onPressed: () async {
                        //                     _tasks[index].notificationEnabled =
                        //                         false;
                        //                     await TaskRepository()
                        //                         .updateTask(_tasks[index]);
                        //                     _loadTasks();

                        //                     Navigator.of(context).pop();
                        //                   },
                        //                   child: const Text('OK'),
                        //                 ),
                        //               ],
                        //             );
                        //           },
                        //         );
                        //       }),

                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: const Text(
                                      'Are you sure you want to delete this task?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteTask(_tasks[index].id!);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskRepository().getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _deleteTask(int id) async {
    await TaskRepository().deleteTask(id);
    _loadTasks();
  }
}
