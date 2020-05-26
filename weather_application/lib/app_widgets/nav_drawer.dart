
import 'package:flutter/material.dart';
import 'package:weather_application/MyRoute.dart';
import 'package:weather_application/app_data/globals.dart' as globals;
import 'package:weather_application/utils/MyColor.dart';
import 'package:weather_application/utils/image_path.dart';

import 'CityWeather.dart';
class NavDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(child:
//          Image.network("https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRdIm6MXieO9EhYjbnUtaZA3zUPaRBg681d4LsH0V0VqKRANGkL&usqp=CAU"),
          Image.asset(ImagePath.appImage),
          padding: EdgeInsets.only(top: 24 , bottom: 24),
          decoration: BoxDecoration(
            color: Color(0xFF217cb5),
          )),
          Container(
            color: globals.navType == NavType.CityList ? MyColor.appLiteOrange : null,
            child: ListTile(
              title: Text("City List",),
              leading: Icon(Icons.location_city,color: MyColor.appOrange ),
              onTap: (){
                Navigator.pop(context);
                if(globals.navType != NavType.CityList){
                  globals.navType = NavType.CityList;
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Container(
            color: globals.navType == NavType.MapView ? MyColor.appLiteOrange : null,
            child: ListTile(
              title: Text("Map View",),
              leading: Icon(Icons.map,color:  MyColor.appOrange),
              onTap: (){
                Navigator.pop(context);
                if(globals.navType != NavType.MapView){
                  if(globals.localPosition==null){
                    Navigator.pushNamed(context,MyRoute.locationHome,arguments: NavType.MapView);
                  }else{
                    globals.navType = NavType.MapView;
                    Navigator.pushNamed(context,MyRoute.mapView);
                  }
                }

              },
            ),
          ),
          Container(
            color: globals.navType == NavType.MyLocation ? MyColor.appLiteOrange : null,
            child: ListTile(
              title: Text("My Location",),
              leading: Icon(Icons.my_location,color: MyColor.appOrange),
              onTap: (){
                Navigator.pop(context);
                  if(globals.localPosition==null){
                    Navigator.pushNamed(context,MyRoute.locationHome,arguments: NavType.MyLocation);
                  }else{
                    Navigator.pushNamed(context,MyRoute.weatherDetail,arguments: CityWeatherScreenArguments(
                        latitude: globals.localPosition.latitude,
                        longitude: globals.localPosition.longitude,
                        isMyLocation: true));
                  }
              },
            ),
          )
        ],
      ),
    );
  }
}

enum NavType{
  CityList,MapView,MyLocation
}

