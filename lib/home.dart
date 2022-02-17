import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    permissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(builder: (context) {
          if (_hasPermissions) {
            return Column(
              children: <Widget>[
                Expanded(child: _buildCompass()),
              ],
            );
          } else {
            return _buildPermissionSheet();
          }
        }),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xff413827),
            ),
          );
        }

        double? direction = snapshot.data!.heading;
        if (direction == null) {
          return const Center(
            child: Text("Sensor not detected in this device!"),
          );
        }

        return Transform.rotate(
          angle: (direction * (math.pi / 180) * -1),
          child: Image.asset('images/compass.png'),
        );
      },
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Need location permission!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 100),
          ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xff413827))),
            child:
                const Text('Open App Settings', style: TextStyle(fontSize: 17)),
            onPressed: () {
              openAppSettings();
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xff413827))),
            child: const Text('Ask for permission',
                style: TextStyle(fontSize: 17)),
            onPressed: () {
              Permission.locationWhenInUse.request().then((ignored) {
                permissionStatus();
              });
            },
          ),
        ],
      ),
    );
  }

  void permissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}
