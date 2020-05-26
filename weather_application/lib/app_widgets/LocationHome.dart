import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_application/app_data/globals.dart' as globals;
import 'package:weather_application/app_widgets/nav_drawer.dart';
import 'package:weather_application/utils/MyColor.dart';
import '../MyRoute.dart';
import 'CityWeather.dart';

class LocationHome extends StatefulWidget {
  @override
  _LocationHomeHomeState createState() =>
      _LocationHomeHomeState();
}

class _LocationHomeHomeState extends State<LocationHome> {
  bool isLocationEnabled = false;
  bool isDisplayLocationRestrictReason = false;
  PermissionStatus geolocationSta;
  Position position;
  bool isFromCityListScreen = false;

  checkLocationPermission() async {
    PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);
    isDisplayLocationRestrictReason = false;
    if (permissionStatus == PermissionStatus.granted) {
      getLocationPosition();
    } else {
      final List<PermissionGroup> permissions = <PermissionGroup>[
        PermissionGroup.location
      ];
      PermissionHandler()
          .requestPermissions(permissions)
          .then((permissionResult) {
        permissionStatus = permissionResult[PermissionGroup.location];
        permissionStatus == PermissionStatus.granted
            ? getLocationPosition()
            : setState(() {
          isLocationEnabled = false;
          geolocationSta = permissionStatus;
          isDisplayLocationRestrictReason = true;
        });
      });
    }
  }

  getLocationPosition() async {
    Position localPosition = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.best);
    if (localPosition == null) {
      print("####DATA : NULL");
    } else {
      print("####DATA: ${localPosition.latitude} + ${localPosition.longitude}");
    }
    if (localPosition != null) {
      if (localPosition.latitude != null && localPosition.longitude != null) {
        if (localPosition.longitude != 0.0 && localPosition.longitude != 0.0) {
          globals.localPosition = localPosition;
          navigateToCityDetail(localPosition);
          return;
        }
      }
    }
    setState(() {
      isLocationEnabled = true;
      position = localPosition;
    });
  }

  navigateToCityDetail(Position position) {
    final NavType navType = ModalRoute.of(context).settings.arguments;
    if(navType==NavType.MapView){
      globals.navType = NavType.MapView;
      Navigator.pushReplacementNamed(context,MyRoute.mapView);
    }else{
      Navigator.of(context).pushReplacementNamed(MyRoute.weatherDetail,arguments: CityWeatherScreenArguments(
        latitude: position.latitude,
        longitude:  position.longitude,
      ));
    }

  }

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
        centerTitle: true,
      ),
      body: Container(
        color: MyColor.appLiteOrange,
        child: Center(
          child: !isLocationEnabled
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      padding: EdgeInsets.only(left: 16.0,top: 8.0,right: 16.0,bottom: 8.0),
                      onPressed: checkLocationPermission,
                      child: Text(
                        "Enable Location",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      color: MyColor.appColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                          side: BorderSide(color: Colors.white)),
                    ),
                    isDisplayLocationRestrictReason
                        ? Text(
                            geolocationSta.toString(),
                            style: TextStyle(
                                color: Colors.red,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                decoration: TextDecoration.none),
                          )
                        : Container(),
                  ],
                )
              : Text(
                  "lat : ${position == null ? "-" : position.latitude} \nlon : ${position == null ? "-" : position.longitude}",
                  style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      decoration: TextDecoration.none)),
        ),
      ),
    );
  }
}
