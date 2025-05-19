import 'package:flutter/material.dart';
import '../model/weather_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  WeatherDataModel? weatherData;
  AirPollutionDataModel? airPollutionData;
  final String weatherApiKey = '661900b7652cefedb11f6e2ddd2b0daa';
  final String baseUrl = 'http://api.openweathermap.org/data/2.5';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      isLoading = true;
    });

    weatherData = await fetchWeatherData();
    airPollutionData = await fetchAirPollutionData(37.5665, 126.9780);

    setState(() {
      isLoading = false;
    });
  }

  Future<WeatherDataModel?> fetchWeatherData() async {
    final Uri url = Uri.parse(
        '$baseUrl/weather?q=Seoul&appid=$weatherApiKey&lang=kr&units=metric');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return WeatherDataModel.fromJson(json);
      } else {
        _showError('날씨 정보를 가져오는데 실패했습니다. 상태 코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _showError('날씨 정보를 가져오는 중 오류가 발생했습니다: $e');
      return null;
    }
  }

  Future<AirPollutionDataModel?> fetchAirPollutionData(
      double latitude, double longitude) async {
    final Uri url = Uri.parse(
        '$baseUrl/air_pollution?lat=$latitude&lon=$longitude&appid=$weatherApiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return AirPollutionDataModel.fromJson(json);
      } else {
        _showError('대기 정보 가져오기 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _showError('대기 정보 가져오기 오류: $e');
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getAirQualityDescription(int aqi) {
    if (aqi <= 50) {
      return '좋음';
    } else if (aqi <= 100) {
      return '보통';
    } else if (aqi <= 150) {
      return '양호';
    } else if (aqi <= 200) {
      return '나쁨';
    } else if (aqi <= 300) {
      return '매우 나쁨';
    } else {
      return '심각';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('날씨',
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeatherData,
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : weatherData == null
            ? const Text('날씨 정보를 가져올 수 없습니다.')
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container( // Container로 Card 감싸기
            constraints: const BoxConstraints(maxWidth: double.infinity), // 최대 너비 설정
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${weatherData!.name}, ${weatherData!.sys.country}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Image.network(
                      'https://openweathermap.org/img/wn/${weatherData!
                          .weather[0]
                          .icon}@2x.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${weatherData!.main.temp}°C',
                      style: const TextStyle(fontSize: 32),
                    ),
                    Text(
                      weatherData!.weather[0].description,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '습도: ${weatherData!.main.humidity}%',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '풍속: ${weatherData!.wind.speed} m/s',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    if (airPollutionData != null)
                      Column(
                        children: [
                          Text(
                            '대기질 지수 (AQI): ${airPollutionData!.list[0].main
                                .aqi}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_getAirQualityDescription(
                                airPollutionData!.list[0].main.aqi)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    else
                      const Text('대기 정보를 가져올 수 없습니다.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}