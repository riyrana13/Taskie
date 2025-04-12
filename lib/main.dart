// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:taskie/screens/task_list_screen.dart';
import 'package:taskie/screens/add_task_screen.dart';
import 'package:taskie/util_files/notification_service.dart';

import 'database/database_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;

  await LocalNotifications.init();

//  handle in terminated state
  var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => const TaskListScreen(),
      ));
    });
  }
  runApp(const TaskieApp());
}

class TaskieApp extends StatelessWidget {
  const TaskieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskie',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const TaskListScreen(),
      routes: {
        AddTaskScreen.routeName: (context) => AddTaskScreen(),
        TaskListScreen.routeName: (context) => const TaskListScreen(),
      },
    );
  }
}
