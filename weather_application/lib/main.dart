import 'package:flutter/material.dart';
import 'package:weather_application/MyRoute.dart';
import 'package:weather_application/app_widgets/CityListApplication.dart';
import 'package:weather_application/app_widgets/CityWeather.dart';
import 'package:weather_application/app_widgets/GeoMapViewApplication.dart';
import 'package:weather_application/app_widgets/LocationHome.dart';
import 'package:weather_application/app_widgets/splash_widget.dart';
import 'package:weather_application/utils/MyColor.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
          primaryColor: MyColor.appColor,
          primaryIconTheme: IconThemeData(color: Colors.white),
          primaryTextTheme: TextTheme(
            title: TextStyle(color: Colors.white),
          )),
      initialRoute: MyRoute.splashScreen,
      debugShowCheckedModeBanner: false,
      routes: {
        MyRoute.splashScreen: (context) => SplashScreen(),
        MyRoute.cityList: (context) => CityListApplication(),
        MyRoute.mapView: (context) => GeoMapViewApplication(),
        MyRoute.weatherDetail: (context) => CityWeather(),
        MyRoute.locationHome: (context) => LocationHome(),
      },
    ));
