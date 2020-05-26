import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:weather_application/app_data/Model.dart';
import 'package:weather_application/app_widgets/base_widget.dart';
import 'package:weather_application/app_data/globals.dart' as globals;
import 'package:weather_application/utils/MyColor.dart';

class CityWeather extends StatelessWidget {
  CityWeatherScreenArguments cityWeatherScreenArguments;
  int networkCode = 1;
  bool isDisplayColorBg = true;
  Future _future;

  String getTitle() {
    if (cityWeatherScreenArguments.isMyLocation == true) {
      return "Current Location Weather";
    } else if (cityWeatherScreenArguments.cityName != null) {
      return cityWeatherScreenArguments.cityName;
    } else if (cityWeatherScreenArguments.weatherReportGlobal != null) {
      return cityWeatherScreenArguments.weatherReportGlobal.name;
    }
    return "No Title";
  }

  @override
  Widget build(BuildContext context) {
    cityWeatherScreenArguments = ModalRoute.of(context).settings.arguments;
    _future = fetchData();
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(getTitle()),
      ),
      body: Center(
        child: FutureBuilder<WeatherReport>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingSpinnerWidget(
                  message: "Fetching Weather Info...",
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return ErrorCenterWidget("SnapSort Error");
                } else if (snapshot.hasData) {
                  if (snapshot.data.statusCode == 200) {
                    WeatherReport weatherReport = snapshot.data;
                    return Container(
                      decoration: isDisplayColorBg
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                  colors: getColorBasedOnClimate(),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  tileMode: TileMode.clamp))
                          : BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(getImageBasedOnClimate()),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.grey, BlendMode.dstATop))),
                      child: parentWidget(weatherReport),
                    );
                  }else if(snapshot.data.statusCode == networkCode){
                    return CenterTextWidget(
                      "No internet connection",
                      textColor: MyColor.appOrange,
                    );
                  } else {
                    return CenterTextWidget(
                      snapshot.data.statusCode.toString(),
                      textColor: MyColor.appOrange,
                    );
                  }
                } else {
                  return ErrorCenterWidget(
                      "UnFortunate Errror Occured - Snapshot has no Data");
                }
              } else {
                return ErrorCenterWidget(
                    "UnFortunate Errror Occured - Connection - ${snapshot.connectionState.toString()}");
              }
            }),
      ),
    );
  }

  Widget parentWidget(weatherReport) {
    return Container(
      margin: EdgeInsets.all(32.0),
      decoration: BoxDecoration(
          color: MyColor.appColor,
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(top: 8),
              child: Image.network("http://openweathermap.org/img/wn/" +
                  weatherReport.weather[0].icon +
                  "@2x.png")),
          Container(
            margin: const EdgeInsets.only(top: 0),
            child: Text(weatherReport.weather[0].main,
                style: TextStyle(
                    color: MyColor.appOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Text(weatherReport.weather[0].description,
                style: TextStyle(
                    color: MyColor.appOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
          Container(
            margin: EdgeInsets.only(top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                leftSideWidget(),
                rightSideWidget(weatherReport)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget leftSideWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTextView("Wind speed", true),
          CustomTextView("Wind direction ", true),
          CustomTextView("Temperature", true),
          CustomTextView("Min Temperature", true),
          CustomTextView("Max Temperature", true),
          CustomTextView("Pressure", true),
          CustomTextView("Humidity", true),
          CustomTextView("Sunrise time", true),
          CustomTextView("Sunset time", true),
        ],
      ),
    );
  }

  Widget rightSideWidget(weatherReport) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTextView(weatherReport.wind.speed.toString() + " m/s", false),
          CustomTextView(weatherReport.wind.deg.toString() + " deg", false),
          CustomTextView(
              printWithCelsiusDeg(weatherReport.mainTempDetails.temp), false),
          CustomTextView(
              printWithCelsiusDeg(weatherReport.mainTempDetails.temp_min),
              false),
          CustomTextView(
              printWithCelsiusDeg(weatherReport.mainTempDetails.temp_max),
              false),
          CustomTextView(
              "${weatherReport.mainTempDetails.pressure} hpa", false),
          CustomTextView(
              weatherReport.mainTempDetails.humidity.toString() + " %", false),
          CustomTextView(
              toDisplayDate(
                  weatherReport.system.sunrise, weatherReport.timezone),
              false),
          CustomTextView(
              toDisplayDate(
                  weatherReport.system.sunset, weatherReport.timezone),
              false),
        ],
      ),
    );
  }

  List<Color> getColorBasedOnClimate() {
    List<Color> colors = [MyColor.appColor, Colors.green];
    if (cityWeatherScreenArguments.weatherReportGlobal == null) {
      return colors;
    }
    if (cityWeatherScreenArguments.weatherReportGlobal.weather[0].id == null) {
      return colors;
    }
    List<Color> whiteList = [Colors.grey[300], Colors.grey, Colors.grey[300]];
    List<Color> blackList = [Colors.black45, Colors.white, Colors.black45];
    int firstChar = int.parse(cityWeatherScreenArguments
        .weatherReportGlobal.weather[0].id
        .toString()[0]);
    switch (firstChar) {
      case 2:
        return blackList;
      case 3:
        return whiteList;
      case 5:
        return blackList;
      case 6:
        return whiteList;
      case 7:
        return whiteList;
      case 8:
        return whiteList;
      default:
        return colors;
    }
  }

  String getImageBasedOnClimate() {
    if (cityWeatherScreenArguments.weatherReportGlobal == null) {
      return "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQzwlgpJ_xfIrLg0PkoAk8iIy2z-SkLMNvIpFeQrTEOgdqtKIxd";
    }
    if (cityWeatherScreenArguments.weatherReportGlobal.weather[0].id == null) {
      return "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQzwlgpJ_xfIrLg0PkoAk8iIy2z-SkLMNvIpFeQrTEOgdqtKIxd";
    }
    int firstChar = int.parse(cityWeatherScreenArguments
        .weatherReportGlobal.weather[0].id
        .toString()[0]);
    switch (firstChar) {
      case 2:
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRW3tKS_oBhM7dQ95oEEDEo1UUHF5_VTOrrsIYmwex27b9bfjxm";
      case 3:
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRK-L4L7Mc_VADiiPo2kAT2Inbz16WFC0vl3sPg3I20bcuT2nRz";
      case 5:
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQUgs08AD0O38Xo9725Ovrf_azb64-zce31xiRrxKqN2rPjHFdT";
      case 6:
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTZsaPlB4yn2FW-USWrd-2xI1PQ_yxUt2NGHOHBLBYNs-AzUQPZ";
      case 7:
        return "https://images.unsplash.com/photo-1530178408322-35e0956c6944?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80";
      case 8:
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRdyeYnTbn1wypvsKah4bUqm3AOTTlL7mROx95hXT8Kh4ewOH6t";
      default:
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQzwlgpJ_xfIrLg0PkoAk8iIy2z-SkLMNvIpFeQrTEOgdqtKIxd";
    }
  }

  String printWithCelsiusDeg(num temp) {
    return temp.toDouble().toString() + " \u2103";
  }

  String toDisplayDate(num time, num timeZone) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(time * 1000);
    return new DateFormat.jms().format(date);
  }

  Future<WeatherReport> fetchData() async {
    if (cityWeatherScreenArguments.weatherReportGlobal == null) {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        var queryParameter = {
          'appid': globals.apiToken,
          'units': 'metric'
        };

        queryParameter.addAll({
          'lat': cityWeatherScreenArguments.latitude.toString(),
          'lon': cityWeatherScreenArguments.longitude.toString()
        });
        print("QUERY#### : " + queryParameter.toString());
        var header = {"Accept": "application/json"};
        try {
          var uri = Uri.http(
              "api.openweathermap.org", "data/2.5/weather", queryParameter);
          print("uri" + uri.toString());
          Response response = await get(uri, headers: header);
          ;
          if (response.statusCode == 200) {
            cityWeatherScreenArguments.weatherReportGlobal =
                WeatherReport.fromJson(json.decode(response.body));
            cityWeatherScreenArguments.weatherReportGlobal.statusCode =
                response.statusCode;
          } else
            cityWeatherScreenArguments.weatherReportGlobal =
                WeatherReport.StatusCode(response.statusCode);
          return cityWeatherScreenArguments.weatherReportGlobal;
        } catch (exe, stackTrace) {
          print("EXEEE" + exe.toString());
          return null;
        }
      }else{
        cityWeatherScreenArguments.weatherReportGlobal = WeatherReport.StatusCode(networkCode);
        return cityWeatherScreenArguments.weatherReportGlobal;
      }
    }else if(cityWeatherScreenArguments.weatherReportGlobal.statusCode==networkCode){
      return cityWeatherScreenArguments.weatherReportGlobal;
    } else {
      cityWeatherScreenArguments.weatherReportGlobal.statusCode = 200;
      return cityWeatherScreenArguments.weatherReportGlobal;
    }
  }
}

class CustomTextView extends StatelessWidget {
  final bool isLeft;
  final String st;

  CustomTextView(this.st, this.isLeft);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Text(
        st,
        style: TextStyle(
            color: isLeft ? MyColor.appLightGreen : MyColor.appLiteOrange,
            fontWeight: FontWeight.bold,
            fontSize: 18),
      ),
    );
  }
}

class CityWeatherScreenArguments {
  num latitude;
  num longitude;
  String cityName;
  WeatherReport weatherReportGlobal;
  bool isMyLocation;

  CityWeatherScreenArguments(
      {this.latitude,
      this.longitude,
      this.cityName,
      this.weatherReportGlobal,
      this.isMyLocation});
}
