library globals;

import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_application/app_data/Model.dart';
import 'package:weather_application/app_widgets/nav_drawer.dart';

Position localPosition;

NavType navType=NavType.CityList;

Set<WeatherReport> weatherReports = Set<WeatherReport>();

String apiToken = 'YourOpenWeatherMapAPIToken';


