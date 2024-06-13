import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();

    // Remove this method to stop OneSignal Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.debug);

    // Initialize OneSignal
    OneSignal.initialize("");

    // Request push notification permission
    OneSignal.Notifications.requestPermission(true);

    // Load notifications from shared preferences
    _loadNotifications();

    // Set up notification click listener
    _setNotificationClickListener();
  }

  void _setNotificationClickListener() {
    OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
      log('Notification clicked');
      setState(() {
        notifications.add(event.jsonRepresentation());
      });
      _saveNotifications();
      print(
          'NOTIFICATION CLICK LISTENER CALLED WITH EVENT: ${event.jsonRepresentation()}');
    });
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications = prefs.getStringList('notifications') ?? [];
    });
  }

  Future<void> _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notifications', notifications);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            SharedPreferences.getInstance().then((value) {
              value.clear();
            });
          },
        ),
        appBar: AppBar(
          title: Text("OneSignal Demo"),
        ),
        body: ListView.builder(
          reverse: true,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            print(index);
            final notificationData = notifications[index];
            return Card(
              child: Text(index.toString() + notificationData),
            );
          },
        ),
      ),
    );
  }
}
