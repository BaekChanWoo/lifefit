import 'package:flutter/material.dart';
import '../model/weather_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  WeatherDataModel? weatherData;
  AirPollutionDataModel? airPollutionData;
  FiveDayForecastModel? fiveDayForecastData; // 5일 예보 데이터 모델 추가
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
    fiveDayForecastData = await fetchFiveDayForecastData(37.5665, 126.9780); // 5일 예보 데이터 가져오기

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

  Future<FiveDayForecastModel?> fetchFiveDayForecastData( // 5일 예보 API 호출 함수
      double latitude, double longitude) async {
    final Uri url = Uri.parse(
        '$baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$weatherApiKey&lang=kr&units=metric');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return FiveDayForecastModel.fromJson(json);
      } else {
        _showError('5일 예보 정보를 가져오는데 실패했습니다. 상태 코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _showError('5일 예보 정보를 가져오는 중 오류가 발생했습니다: $e');
      return null;
    }
  }

  //에러표시
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 미세먼지(PM10) 농도 상태
  String _getPm10Status(double pm10) {
    if (pm10 >= 0 && pm10 <= 30) {
      return '좋음';
    } else if (pm10 >= 31 && pm10 <= 80) {
      return '보통';
    } else if (pm10 >= 81 && pm10 <= 150) {
      return '나쁨';
    } else {
      return '매우 나쁨';
    }
  }

  // 초미세먼지(PM2.5) 농도 상태
  String _getPm25Status(double pm25) {
    if (pm25 >= 0 && pm25 <= 15) {
      return '좋음';
    } else if (pm25 >= 16 && pm25 <= 50) {
      return '보통';
    } else if (pm25 >= 51 && pm25 <= 100) {
      return '나쁨';
    } else {
      return '매우 나쁨';
    }
  }

  // 미세먼지 상태에 따른 이미지 경로 반환 함수
  String _getAirQualityImagePath(String status) {
    switch (status) {
      case '좋음':
        return 'assets/img/weather_good.png';
      case '보통':
        return 'assets/img/weather_normal.png';
      case '나쁨':
        return 'assets/img/weather_bad.png';
      case '매우 나쁨':
        return 'assets/img/weather_verybad.png';
      default:
        return 'assets/img/weather_good.png'; // 기본 이미지
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text(
            '날씨',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    constraints: const BoxConstraints(maxWidth: double.infinity),
                    child: _buildWeatherCard1()
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxWidth: double.infinity),
                  child: _buildWeatherCard2(), // 5일 예보를 표시하는 카드
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard1() {
    return Card(
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // 날씨 정보와 미세먼지 정보를 가로로 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 요소들 간 간격 균등하게 분배
              crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
              children: [
                // 미세먼지 (PM10) 및 초미세먼지 (PM2.5) 정보
                if (airPollutionData != null)
                  Expanded( // 공간을 차지하도록 Expanded 추가
                    child: Column( // 미세먼지/초미세먼지 전체를 하나의 Column으로 묶음
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row( // PM10과 PM2.5를 가로로 나열
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // 미세먼지 (PM10)
                            Column(
                              children: [
                                const Text(
                                  '미세먼지',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                // 초미세먼지 이미지 추가
                                Image.asset(
                                  _getAirQualityImagePath(_getPm25Status(airPollutionData!.list[0].components.pm2_5)),
                                  width: 70, // 날씨 아이콘과 동일한 크기
                                  height: 70, // 날씨 아이콘과 동일한 크기
                                ),
                                Text(
                                  '${airPollutionData!.list[0].components.pm10.round()} ㎍/㎥',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  _getPm10Status(airPollutionData!.list[0].components.pm10),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20), // 미세먼지 정보와 초미세먼지 정보 사이 간격
                            // 초미세먼지 (PM2.5)
                            Column(
                              children: [
                                const Text(
                                  '초미세먼지',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                // 초미세먼지 이미지 추가
                                Image.asset(
                                  _getAirQualityImagePath(_getPm25Status(airPollutionData!.list[0].components.pm2_5)),
                                  width: 70, // 날씨 아이콘과 동일한 크기
                                  height: 70, // 날씨 아이콘과 동일한 크기
                                ),
                                Text(
                                  '${airPollutionData!.list[0].components.pm2_5.round()} ㎍/㎥',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  _getPm25Status(airPollutionData!.list[0].components.pm2_5),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  const Expanded(child: Text('대기 정보를 가져올 수 없습니다.')), // 대기 정보 없을 때 처리

                const SizedBox(width: 20), // 미세먼지 정보와 날씨 정보 사이 간격

                // 날씨 정보
                Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 날씨 정보 세로 중앙 정렬
                  children: [
                    Text(
                      '날씨',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Image.network(
                      'https://openweathermap.org/img/wn/${weatherData!.weather[0].icon}@2x.png',
                      width: 70, // 아이콘 크기
                      height: 70, // 아이콘 크기
                    ),
                    Text(
                      '${weatherData!.main.temp}°C',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      weatherData!.weather[0].description,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20), // 전체 섹션 하단 간격
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard2() {
    if (fiveDayForecastData == null) {
      return const Text('5일 예보 정보를 가져올 수 없습니다.');
    }

    // 오늘 날짜를YYYY-MM-DD 형식으로 가져옵니다.
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 예보 데이터를 오늘 예보와 이후 예보로 분리합니다.
    List<ForecastItem> todayForecast = [];
    Map<String, List<ForecastItem>> subsequentForecasts = {};

    for (var item in fiveDayForecastData!.list) {
      String itemDate = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(item.dt * 1000));
      if (itemDate == todayDate) {
        todayForecast.add(item);
      } else {
        if (!subsequentForecasts.containsKey(itemDate)) {
          subsequentForecasts[itemDate] = [];
        }
        subsequentForecasts[itemDate]!.add(item);
      }
    }

    //하단 예보
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 금일 예보 섹션
            const Text(
              '금일 예보',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: todayForecast.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(item.dt * 1000)), style: const TextStyle(fontSize: 14)),
                        Image.network(
                          'https://openweathermap.org/img/wn/${item.weather[0].icon}@2x.png',
                          width: 50,
                          height: 50,
                        ),
                        Text('${item.main.temp.round()}°C', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20), // 금일 예보와 이후 예보 사이 간격

            // 이후 예보 섹션
            const Text(
              '이후 예보',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicWidth(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subsequentForecasts.entries.map((entry) {
                    String date = entry.key;
                    List<ForecastItem> dailyForecasts = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MM/dd (E)', 'ko_KR').format(DateTime.parse(date)),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...dailyForecasts.map((item) {
                            String time = DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(item.dt * 1000));
                            return Column(
                              children: [
                                Text(time, style: const TextStyle(fontSize: 14)),
                                Image.network(
                                  'https://openweathermap.org/img/wn/${item.weather[0].icon}@2x.png',
                                  width: 50,
                                  height: 50,
                                ),
                                Text('${item.main.temp.round()}°C', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                              ],
                            );
                          }).toList(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}