

import 'package:flutter/material.dart';
import 'package:weather_application/utils/MyColor.dart';

class LoadingSpinnerWidget extends StatelessWidget {
  final String message;

  LoadingSpinnerWidget({this.message = "Loading"});

  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: <Widget>[ Container(
        decoration: BoxDecoration(color: MyColor.appLiteOrange,borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Padding(
          padding: const EdgeInsets.only(left:24.0,right: 24.0,top: 16.0,bottom: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyColor.appOrange),),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(message ?? "Loading",style: TextStyle(color: MyColor.appColor,fontSize: 18.0),)),
              )
            ],
          ),
        ),
      ),]
    );
  }
}

class ErrorCenterWidget extends StatelessWidget {
  ErrorCenterWidget(this.error);

  final Object error;

  @override
  Widget build(BuildContext context) {
    return CenterTextWidget(this.error,textColor: Colors.red);
  }
}

// ignore: must_be_immutable
class CenterTextWidget extends StatelessWidget {
  CenterTextWidget(this.message,{this.textColor});
  var  textColor;
  final Object message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message ?? "",
        style: TextStyle(color: textColor ?? Colors.black),
      ),
    );
  }
}