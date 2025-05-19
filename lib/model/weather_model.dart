class WeatherDataModel {
  final Coord coord;
  final List<Weather> weather;
  final String base;
  final MainWeatherInfo main;
  final int visibility;
  final Wind wind;
  final Clouds clouds;
  final int dt;
  final Sys sys;
  final int timezone;
  final int id;
  final String name;
  final int cod;

  WeatherDataModel({
    required this.coord,
    required this.weather,
    required this.base,
    required this.main,
    required this.visibility,
    required this.wind,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    required this.cod,
  });

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) {
    return WeatherDataModel(
      coord: Coord.fromJson(json['coord'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((item) => Weather.fromJson(item as Map<String, dynamic>))
          .toList(),
      base: json['base'] as String,
      main: MainWeatherInfo.fromJson(json['main'] as Map<String, dynamic>),
      visibility: json['visibility'] as int,
      wind: Wind.fromJson(json['wind'] as Map<String, dynamic>),
      clouds: Clouds.fromJson(json['clouds'] as Map<String, dynamic>),
      dt: json['dt'] as int,
      sys: Sys.fromJson(json['sys'] as Map<String, dynamic>),
      timezone: json['timezone'] as int,
      id: json['id'] as int,
      name: json['name'] as String,
      cod: json['cod'] as int,
    );
  }
}

class Coord {
  final double lon;
  final double lat;

  Coord({
    required this.lon,
    required this.lat,
  });

  factory Coord.fromJson(Map<String, dynamic> json) {
    return Coord(
      lon: (json['lon'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
    );
  }
}

class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'] as int,
      main: json['main'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }
}

class MainWeatherInfo { // 'Main' 대신 'MainWeatherInfo'로 클래스명 변경 (충돌 방지)
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int? seaLevel; // API 응답에 따라 null일 수 있음
  final int? grndLevel; // API 응답에 따라 null일 수 있음

  MainWeatherInfo({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    this.seaLevel,
    this.grndLevel,
  });

  factory MainWeatherInfo.fromJson(Map<String, dynamic> json) {
    return MainWeatherInfo(
      temp: (json['temp'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      tempMin: (json['temp_min'] as num).toDouble(),
      tempMax: (json['temp_max'] as num).toDouble(),
      pressure: json['pressure'] as int,
      humidity: json['humidity'] as int,
      seaLevel: json['sea_level'] as int?,
      grndLevel: json['grnd_level'] as int?,
    );
  }
}

class Wind {
  final double speed;
  final int deg;
  final double? gust; // API 응답에 따라 null일 수 있음

  Wind({
    required this.speed,
    required this.deg,
    this.gust,
  });

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: (json['speed'] as num).toDouble(),
      deg: json['deg'] as int,
      gust: (json['gust'] as num?)?.toDouble(),
    );
  }
}

class Clouds {
  final int all;

  Clouds({
    required this.all,
  });

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(
      all: json['all'] as int,
    );
  }
}

class Sys {
  final String? country; // API 응답에 따라 null일 수 있음
  final int sunrise;
  final int sunset;
  // API에 따라 type, id 등이 추가될 수 있음
  // final int? type;
  // final int? id;

  Sys({
    this.country,
    required this.sunrise,
    required this.sunset,
    // this.type,
    // this.id,
  });

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(
      country: json['country'] as String?,
      sunrise: json['sunrise'] as int,
      sunset: json['sunset'] as int,
      // type: json['type'] as int?,
      // id: json['id'] as int?,
    );
  }
}

class AirPollutionDataModel {
  final Coord coord;
  final List<AirQuality> list;

  AirPollutionDataModel({required this.coord, required this.list});

  factory AirPollutionDataModel.fromJson(Map<String, dynamic> json) {
    return AirPollutionDataModel(
      coord: Coord.fromJson(json['coord']),
      list: (json['list'] as List)
          .map((item) => AirQuality.fromJson(item))
          .toList(),
    );
  }
}

class AirQuality {
  final MainAirQuality main;
  final Components components;
  final int dt;

  AirQuality({required this.main, required this.components, required this.dt});

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    return AirQuality(
      main: MainAirQuality.fromJson(json['main']),
      components: Components.fromJson(json['components']),
      dt: json['dt'] as int,
    );
  }
}

class MainAirQuality {
  final int aqi;

  MainAirQuality({required this.aqi});

  factory MainAirQuality.fromJson(Map<String, dynamic> json) {
    return MainAirQuality(
      aqi: json['aqi'] as int,
    );
  }
}

class Components {
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm2_5;
  final double pm10;
  final double nh3;

  Components({
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
  });

  factory Components.fromJson(Map<String, dynamic> json) {
    return Components(
      co: (json['co'] as num).toDouble(),
      no: (json['no'] as num).toDouble(),
      no2: (json['no2'] as num).toDouble(),
      o3: (json['o3'] as num).toDouble(),
      so2: (json['so2'] as num).toDouble(),
      pm2_5: (json['pm2_5'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      nh3: (json['nh3'] as num).toDouble(),
    );
  }
}
