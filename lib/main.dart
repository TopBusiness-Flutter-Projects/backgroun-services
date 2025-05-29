import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:location/location.dart';
import 'dart:convert';

import 'app.dart';

const fetchBackgroundTask = "fetchLocationTask";

void callbackDispatcher() {
  // Workmanager().executeTask((task, inputData) async {
  //   if (task == fetchBackgroundTask) {
  //     Location location = Location();
  //     bool serviceEnabled = await location.serviceEnabled();
  //     if (!serviceEnabled) {
  //       serviceEnabled = await location.requestService();
  //       if (!serviceEnabled) return Future.value(false);
  //     }

  //     PermissionStatus permissionGranted = await location.hasPermission();
  //     if (permissionGranted == PermissionStatus.denied) {
  //       permissionGranted = await location.requestPermission();
  //       if (permissionGranted != PermissionStatus.granted) {
  //         return Future.value(false);
  //       }
  //     }

  //     LocationData locationData = await location.getLocation();

  //     final dio = Dio();
  //     try {
  //       final response = await dio.post(
  //         "https://your-api.com/location",
  //         options: Options(
  //           headers: {"Content-Type": "application/json"},
  //         ),
  //         data: {
  //           "latitude": locationData.latitude,
  //           "longitude": locationData.longitude,
  //           "timestamp": DateTime.now().toIso8601String(),
  //         },
  //       );

  //       return response.statusCode == 200;
  //     } catch (e) {
  //       print("Dio Error: $e");
  //       return false;
  //     }
  //   }

  //   return Future.value(false);
  // });

Workmanager().executeTask((task, inputData) async {
  if (task == fetchBackgroundTask) {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return Future.value(false);
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.value(false);
      }
    }

    LocationData locationData = await location.getLocation();

    await showLocationNotification(
      locationData.latitude ?? 0.0,
      locationData.longitude ?? 0.0,
    );

    return Future.value(true);
  }

  return Future.value(false);
});


}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  await Workmanager().registerPeriodicTask(
    "1",
    fetchBackgroundTask,
    frequency: Duration(hours: 2),
    initialDelay: Duration(minutes: 1),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  runApp(MyApp());
}
Future<void> showLocationNotification(double lat, double lng) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'location_channel_id',
    'Location Updates',
    channelDescription: 'Notification channel for location updates',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Location Update',
    'Lat: $lat, Lng: $lng',
    platformChannelSpecifics,
  );
}
