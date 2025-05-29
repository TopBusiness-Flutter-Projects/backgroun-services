import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Location',
      home: Scaffold(
        appBar: AppBar(title: Text('Background Location')),
        body: Center(
          child: Text('Location background service running...'),
        ),
      ),
    );
  }
}
