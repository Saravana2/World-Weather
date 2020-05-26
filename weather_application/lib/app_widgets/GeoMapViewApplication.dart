import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:weather_application/app_data/Model.dart';
import 'package:weather_application/app_data/globals.dart' as globals;
import 'package:weather_application/utils/MyColor.dart';

import '../MyRoute.dart';
import 'CityWeather.dart';
import 'nav_drawer.dart';

class GeoMapViewApplication extends StatefulWidget {
  @override
  _GeoMapViewApplicationState createState() => _GeoMapViewApplicationState();
}

class _GeoMapViewApplicationState extends State<GeoMapViewApplication> {
  final Set<Marker> _markers = Set<Marker>();
  LatLng _latLong;
  LatLng _lastMapPosition;
  GoogleMapController _googleMapController;
  bool _isLoading = false;
  bool _showNetworkError = true;
  var _subscription;

  @override
  void initState() {
    globals.navType = NavType.MapView;
    var lat = globals.localPosition?.latitude ?? 11.00555;
    var lon = globals.localPosition?.longitude ?? 76.96612;
    _latLong = LatLng(lat, lon);
    _lastMapPosition = LatLng(lat, lon);
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          _showNetworkError = false;
        } else {
          _showNetworkError = true;
        }
      });
    });

    if (globals.weatherReports.length == 0) {
      _checkNearLocationWeather();
    } else {
      _checkAndDisplay();
    }
    super.initState();
  }

  _checkAndDisplay() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _showNetworkError = false;
      });
    }

    globals.weatherReports.forEach((weatherReport) async {
      var marker = await getMarker(weatherReport);
      globals.weatherReports.add(weatherReport);
      setState(() {
        _markers.add(marker);
      });
    });
  }

  _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _checkNearLocationWeather() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      var queryParameter = {
        'appid': globals.apiToken,
        'units': 'metric',
        'lat': _lastMapPosition.latitude.toString(),
        'lon': _lastMapPosition.longitude.toString(),
        'cnt': (50).toString()
      };
      print("QUERY#### : " + queryParameter.toString());

      var uri =
          Uri.http("api.openweathermap.org", "data/2.5/find", queryParameter);
      print("URI Near by Position" + uri.toString());
      var header = {"Accept": "application/json"};
      setState(() {
        _isLoading = true;
        _showNetworkError = false;
      });
      Response response = await get(uri, headers: header);
      debugPrint("JSON: ${json.decode(response.body).toString()}");
      WeatherReportList weatherReportList;
      try {
        weatherReportList =
            WeatherReportList.fromJson(json.decode(response.body));
      } catch (e) {
        print("Exception " + e.toString());
      }
      if (weatherReportList.weatherReportList != null)
        weatherReportList.weatherReportList
            .asMap()
            .forEach((index, weatherReport) async {
          var marker = await getMarker(weatherReport);
          globals.weatherReports.add(weatherReport);
          setState(() {
            _markers.add(marker);
            if (index == weatherReportList.weatherReportList.length - 1) {
              _isLoading = false;
            }
          });
          if (index == weatherReportList.weatherReportList.length - 1) {
            if (_googleMapController != null)
              _googleMapController
                  .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: _lastMapPosition,
                zoom: 8,
              )));
          }
        });
    } else {
      setState(() {
        _showNetworkError = true;
      });
    }
  }

  Future<Marker> getMarker(weatherReport) async {
    var request = await get("http://openweathermap.org/img/wn/" +
        weatherReport.weather[0].icon +
        "@2x.png");
    return Marker(
        markerId: MarkerId(
            "${weatherReport.coordinateData.lat} : ${weatherReport.coordinateData.lon}"
                .toString()),
        icon:
            BitmapDescriptor.fromBytes(request.bodyBytes.buffer.asUint8List()),
        position: LatLng(weatherReport.coordinateData.lat.toDouble(),
            weatherReport.coordinateData.lon.toDouble()),
        /*infoWindow: InfoWindow(
            onTap: () => Navigator.of(context).pushNamed(MyRoute.weatherDetail,arguments: CityWeatherScreenArguments(
              latitude: weatherReport.coordinateData.lat,
              longitude: weatherReport.coordinateData.lon,
              cityName: weatherReport.name,)),
            title:
            "${weatherReport.weather[0].main}  ${weatherReport.mainTempDetails.temp.toDouble().toString()} \u2103",
            snippet:
            'Lat ${weatherReport.coordinateData.lat} :  Lon ${weatherReport.coordinateData.lon} ')*/
        onTap: () {
          _showWeatherDetailsOnBottom(weatherReport);
        });
  }

  Future<bool> _onBackPressed() async {
    _subscription.cancel();
    return !_isLoading;
  }

  @override
  void dispose() {
    globals.navType = NavType.CityList;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            drawer: NavDrawer(),
            appBar: mapViewTab(),
            body: _showNetworkError
                ? displayNoInternetMapView()
                : displayMapView()),
        onWillPop: _onBackPressed);
  }

  Widget displayNoInternetMapView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
            margin: EdgeInsets.all(20.0),
            width: 400,
            height: 400,
            child: googleMapWidget()),
        displayNoInternetView()
      ],
    );
  }

  Widget googleMapWidget() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      mapType: MapType.hybrid,
      initialCameraPosition: getCameraPosition(),
      markers: _markers,
      onCameraMove: _onCameraMove,
    );
  }

  Widget displayNoInternetView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.signal_cellular_connected_no_internet_4_bar,
          color: MyColor.appColor,
        ),
        Container(
            margin: EdgeInsets.only(top: 12.0),
            child: Text("No internet connection")),
      ],
    );
  }

  Widget displayMapView() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
            color: Colors.white,
            padding: EdgeInsets.all(8.0),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: googleMapWidget(),
                ),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Icon(
                          Icons.my_location,
                          color: Colors.red,
                        ),
                ),
              ],
            )),
        SizedBox(
            width: double.infinity,
            child: ButtonTheme(
              height: 50.0,
              child: FlatButton(
                  padding: EdgeInsets.all(8.0),
                  color: MyColor.appColor,
                  onPressed: _isLoading ? null : _checkNearLocationWeather,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Text(
                    "Check Current View Location Weather",
                    style: TextStyle(color: Colors.white),
                  )),
            ))
      ],
    );
  }

  _showWeatherDetailsOnBottom(WeatherReport weatherReport) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              color: MyColor.appLiteOrange,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.network(
                            "http://openweathermap.org/img/wn/" +
                                weatherReport.weather[0].icon +
                                "@2x.png",
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(right: 4.0,top: 4.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "${weatherReport.mainTempDetails.temp.toInt().toString()}",
                                style: TextStyle(
                                    color: MyColor.appColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24),
                              ),
                              Text("\u2103",
                                  style: TextStyle(
                                      color: MyColor.appColor, fontSize: 14))
                            ],
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(height: 8,),
                        Text(weatherReport.weather[0].main,
                            style: TextStyle(
                                color: MyColor.appColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 24)),
                        SizedBox(height: 8,),
                        Text(weatherReport.weather[0].description,
                            style: TextStyle(
                                color: MyColor.appColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        Container(
                          margin: EdgeInsets.only(top: 8.0,bottom: 4.0),
                          child: Row(
                              children: <Widget>[
                                Icon(Icons.location_on,color: Colors.red,),
                                SizedBox(width: 5),
                                Text("${weatherReport.coordinateData.lat.toDouble()} , ${weatherReport.coordinateData.lon.toDouble()}",style: TextStyle(color: MyColor.appColor),),
                                SizedBox(width: 10),
                                Icon(Icons.location_city,color: Colors.red,),
                                SizedBox(width: 5),
                                Text(weatherReport.name, style: TextStyle(color: MyColor.appColor,))
                              ]),
                        ),

                      ],
                    )
                  ],
                ),
                RaisedButton(onPressed: (){_navigateToWeatherDetail(weatherReport);},
                  color: MyColor.appColor,
                  child: Padding(padding: EdgeInsets.only(top: 16,bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("go to Weather Detail",style: TextStyle(color: Colors.white,fontSize: 18),),
                        Container(child: Icon(Icons.arrow_forward,color: Colors.white,),margin: EdgeInsets.only(left: 8.0),)
                      ],
                    ) ,),)
              ],
            ),
          );
        });
  }

  _navigateToWeatherDetail(weatherReport){
        Navigator.of(context).pushNamed(MyRoute.weatherDetail,arguments: CityWeatherScreenArguments(
      latitude: weatherReport.coordinateData.lat,
      longitude: weatherReport.coordinateData.lon,
      cityName: weatherReport.name,));
  }

  Widget mapViewTab() {
    return AppBar(
      iconTheme: IconThemeData(
          opacity: setOpacityForBackButton(), color: Colors.white),
      title: Text(
        "Map View",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  CameraPosition getCameraPosition() {
    return CameraPosition(
      target: _latLong,
      zoom: 8,
    );
  }

  double setOpacityForBackButton() {
    if (_isLoading)
      return 0.0;
    else
      return 1.0;
  }
}
