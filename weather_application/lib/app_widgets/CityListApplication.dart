import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weather_application/app_data/Model.dart';
import 'package:weather_application/app_data/globals.dart' as globals;
import 'package:weather_application/app_widgets/base_widget.dart';
import 'package:weather_application/utils/MyColor.dart';
import '../MyRoute.dart';
import 'CityWeather.dart';
import 'GeoMapViewApplication.dart';
import 'LocationHome.dart';
import 'nav_drawer.dart';

class CityListApplication extends StatefulWidget {
  @override
  _WeatherList createState() => _WeatherList();
}

class _WeatherList extends State<CityListApplication> {
  List<CityData> cityList = [];
  List<CityData> originalCityList = [];
  TextEditingController controller = TextEditingController();
  Future futureCityList;
  bool showClearButtonForSearch = false;

  _WeatherList();

  @override
  void initState() {
    super.initState();
    globals.navType = NavType.CityList;
    futureCityList = fetchData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("City List",),
        centerTitle: true,
      ),
      body: Container(
        child: FutureBuilder<List<CityData>>(
            future: futureCityList,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorCenterWidget(snapshot.error);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: LoadingSpinnerWidget(message: "Fetching...",),
                );
              } else if (snapshot.hasData) {
                return Container(
                  child: Column(
                    children: <Widget>[
                      getSearchView(),
                      Divider(color: MyColor.appOrange,),
                      Expanded(
                          child: cityList.length != 0
                              ? cityListBuilder()
                              : noCitiesWidget()
                      )
                    ],
                  ),
                );
              } else {
                return ErrorCenterWidget("Unfortunately Error Occured");
              }
            }),
      ),
    );
  }

  Widget getSearchView(){
    return ListTile(
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: 'search city',
            border: InputBorder.none),
        onChanged: (text) => onSearchTextChanged(text),
      ),
      trailing: showClearButtonForSearch
          ? IconButton(
        icon: Icon(Icons.cancel,color:  MyColor.appOrange,),
        onPressed: () {
          controller.clear();
          onSearchTextChanged('');
        },
      )
          : Icon(Icons.search,color: MyColor.appOrange,),
    );
  }

  Widget noCitiesWidget(){
    return CenterTextWidget("No Cities Found",textColor: MyColor.appColor);
  }

  Widget cityListBuilder(){
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemBuilder:
          (BuildContext context, int index) {
        return GestureDetector(
          onTap: (){
            navigateToWeatherDetail(cityList[index]);
            },
          child: Card(
            color: MyColor.appColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(cityList[index].name,style: TextStyle(color: Colors.white,fontSize: 18.0),)
                  ),
                  Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Row(
                        children: <Widget>[
                          countryNameWidget(cityList[index].country),
                          Padding(
                              padding: EdgeInsets.only(left:24.0),
                              child: Row(
                                children: <Widget>[
                          Icon(Icons.location_on,color: Colors.red,),
                          Text("${cityList[index].coordinateData.lat.toDouble()} , ${cityList[index].coordinateData.lon.toDouble()}",style: TextStyle(color: Colors.white),),
                                  ]))

                        ],
                      ))
                ],
              ),
            ),
          ),
        );
      },
      itemCount: cityList.length,
    );
  }

  Widget countryNameWidget(String country){
    String cty= "N/A";
    if(country!=null && country.isNotEmpty ){
      cty = country;
    }
      return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(cty,style: TextStyle(fontSize: 12.0),),
      ),
      decoration: BoxDecoration(shape:BoxShape.rectangle,color:Colors.pink.shade100,borderRadius: BorderRadius.all(Radius.circular(7.0))),
    );
  }

  navigateToWeatherDetail(CityData cityData){
    Navigator.of(context).pushNamed(MyRoute.weatherDetail,arguments: CityWeatherScreenArguments(
      latitude: cityData.coordinateData.lat,
      longitude:  cityData.coordinateData.lon,
      cityName: cityData.name,
    ));
  }

  onSearchTextChanged(String text) async {
    cityList.clear();
    if (text.isEmpty) {
      setState(() {
        cityList.addAll(originalCityList);
        showClearButtonForSearch = false;
      });
    } else {
      setState(() {
        showClearButtonForSearch = true;
        cityList.addAll(originalCityList
            .where((city) =>
                city.country.toLowerCase().contains(text.toLowerCase()) ||
                city.name.toLowerCase().contains(text.toLowerCase()))
            .toList());
      });
    }
  }

  Future<List<CityData>> fetchData(context) async {
    cityList.clear();
    if (originalCityList.length == 0) {
      String json = await DefaultAssetBundle.of(context)
          .loadString('assets/city.list.json');
      originalCityList.addAll(await compute(parseJson, json));
      cityList.addAll(originalCityList);
      return originalCityList;
    } else {
      cityList.addAll(originalCityList);
      return originalCityList;
    }
  }

  static List<CityData> parseJson(String response) {
    if (response == null || response == "null") {
      return [];
    }
    try {
      final parsed = json.decode(response).cast<Map<String, dynamic>>();
      var list = List<CityData>.from(
          parsed.map((json) => new CityData.fromJson(json)).toList());
      list.sort((cityDate1, cityDate2) =>
          cityDate1.country.compareTo(cityDate2.country));

      return list
          /*.where((city) => city.country == "IN" && city.name.startsWith("Coimba"))
          .toList()*/
          ;
    } catch (exc, stacktrace) {
      print("ERROR" + exc.toString());
      return [];
    }
  }
}

