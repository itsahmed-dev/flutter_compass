import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:compass_app/packages.dart';

void main() => runApp(CompassApp());

class CompassApp extends StatefulWidget {
  const CompassApp({super.key});

  @override
  State<CompassApp> createState() => _CompassAppState();
}

class _CompassAppState extends State<CompassApp> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compass App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (_hasPermission) {
                return _buildCompass();
              } else {
                return _buildPermission();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        //* Error
        if (snapshot.hasError) {
          return Center(
            child: Text('Error reading heading: ${snapshot.error}'),
          );
        }

        //* Waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        double? direction = snapshot.data!.heading;

        if (direction == null) {
          return Center(
            child: Text('Device does not have sensors'),
          );
        }
        return Center(
          child: Container(
            padding: EdgeInsets.all(25),
            child: Transform.rotate(
              angle: direction * (math.pi / 180) * -1,
              child: Image.asset(
                'assets/compass.png',
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermission() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Permission.locationWhenInUse.request().then(
                (value) => _fetchPermissionStatus(),
              );
        },
        child: Text('Location Permission'),
      ),
    );
  }
}
