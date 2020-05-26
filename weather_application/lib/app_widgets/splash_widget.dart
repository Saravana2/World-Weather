

import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_application/MyRoute.dart';
import 'package:weather_application/app_data/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:weather_application/utils/image_path.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLocationPermission(context);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF217cb5),
      child: Center(
//        child:   Image.network("https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRdIm6MXieO9EhYjbnUtaZA3zUPaRBg681d4LsH0V0VqKRANGkL&usqp=CAU"),
      child: Image.asset(ImagePath.appImage),
      ),
    );
  }

  checkLocationPermission(BuildContext context) async {
    PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);

    if (permissionStatus == PermissionStatus.granted) {
      globals.localPosition = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.best);
    }
    startTime(context);
  }

  startTime(BuildContext context)async{
    Timer(Duration(seconds: 3),(){navigationPage(context);});
  }

  navigationPage(BuildContext context){
    Navigator.pushReplacementNamed(context,MyRoute.cityList);
  }
}
