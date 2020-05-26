class CityData {
  num id;
  String name;
  String country;
  CoordinateData coordinateData;

  CityData(this.id, this.name, this.country, this.coordinateData);

  factory CityData.fromJson(Map<String, dynamic> json) {
    return new CityData(json['id'] as num, json['name'] as String,
        json['country'] as String, CoordinateData.fromJson(json['coord']));
  }
}

class CoordinateData {
  num lon;
  num lat;

  CoordinateData(this.lon, this.lat);

  factory CoordinateData.fromJson(Map<String, dynamic> json) {
    return new CoordinateData(json['lon'] as num, json['lat'] as num);
  }
}

class WeatherReportList {
  int count;
  List<WeatherReport> weatherReportList;

  WeatherReportList(this.count, this.weatherReportList);

  factory WeatherReportList.fromJson(Map<String, dynamic> json) {
    return new WeatherReportList(
        json['count'] as int,
        List<WeatherReport>.from(json['list']
            .cast<Map<String, dynamic>>()
            .map((jsonStr) => new WeatherReport.fromJson(jsonStr))
            .toList()));
  }
}

class WeatherReport {
  num id;
  String name;
  num cod;
  String base;
  num dt;
  num visibility;
  num timezone;
  Clouds clouds;
  Wind wind;
  System system;
  MainTempDetails mainTempDetails;
  List<Weather> weather;
  CoordinateData coordinateData;
  int statusCode;

  WeatherReport(
      this.id,
      this.name,
      this.cod,
      this.base,
      this.dt,
      this.visibility,
      this.timezone,
      this.clouds,
      this.wind,
      this.system,
      this.mainTempDetails,
      this.weather,
      this.coordinateData);

  WeatherReport.StatusCode(this.statusCode);

  factory WeatherReport.fromJson(Map<String, dynamic> data) {
    return new WeatherReport(
      data['id'] as num,
      data['name'] as String,
      data['cod'] as num,
      data['base'] as String,
      data['dt'] as num,
      data['visibility'] as num,
      data['timezone'] as num,
      Clouds.fromJson(data['clouds']),
      Wind.fromJson(data['wind']),
      System.fromJson(data['sys']),
      MainTempDetails.fromJson(data['main']),
      List<Weather>.from(data['weather']
          .cast<Map<String, dynamic>>()
          .map((jsonStr) => new Weather.fromJson(jsonStr))
          .toList()),
      CoordinateData.fromJson(data['coord']),
    );
  }
}

class Wind {
  num speed;
  num deg;

  Wind(this.speed, this.deg);

  factory Wind.fromJson(Map<String, dynamic> json) {
    return new Wind(json['speed'] as num, json['deg'] as num);
  }
}

class System {
  num sunrise;
  num sunset;

  System(this.sunrise, this.sunset);

  factory System.fromJson(Map<String, dynamic> json) {
    return new System(json['sunrise'] as num, json['sunset'] as num);
  }
}

class MainTempDetails {
  num temp;
  num pressure;
  num humidity;
  num temp_min;
  num temp_max;

  MainTempDetails(
      this.temp, this.pressure, this.humidity, this.temp_min, this.temp_max);

  factory MainTempDetails.fromJson(Map<String, dynamic> json) {
    return new MainTempDetails(
        json['temp'] as num,
        json['pressure'] as num,
        json['humidity'] as num,
        json['temp_min'] as num,
        json['temp_max'] as num);
  }
}

class Weather {
  num id;
  String main;
  String description;
  String icon;

  Weather(this.id, this.main, this.description, this.icon);

  factory Weather.fromJson(Map<String, dynamic> json) {
    return new Weather(json['id'] as num, json['main'] as String,
        json['description'] as String, json['icon'] as String);
  }
}

class Clouds {
  num all;

  Clouds(this.all);

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return new Clouds(json['all'] as num);
  }
}
