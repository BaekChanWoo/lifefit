// home_weather.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // 위치 정보용
import 'package:http/http.dart' as http; // API 호출용
import 'dart:convert'; // JSON 디코딩용

// 프로젝트 구조에 맞게 이 import 경로를 조정하세요.
import '../../model/weather_model.dart';

class HomeWeatherWidget extends StatefulWidget {
  // API 키를 외부에서 주입받고 싶다면 생성자에 추가할 수 있습니다.
  // final String apiKey;
  // const HomeWeatherWidget({Key? key, required this.apiKey}) : super(key: key);

  const HomeWeatherWidget({Key? key}) : super(key: key);

  @override
  _HomeWeatherWidgetState createState() => _HomeWeatherWidgetState();
}

class _HomeWeatherWidgetState extends State<HomeWeatherWidget> {
  WeatherDataModel? _weatherData;
  AirPollutionDataModel? _airPollutionData;
  bool _isLoading = true;
  String? _errorMessage;

  // 중요: 실제 API 키를 사용하세요. weather.dart 파일에 있던 것을 참조합니다.
  final String _weatherApiKey = '661900b7652cefedb11f6e2ddd2b0daa';
  final String _baseUrl = 'http://api.openweathermap.org/data/2.5';

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _errorMessage = '위치 서비스가 비활성화되어 있습니다.';
        });
      }
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _errorMessage = '위치 정보 접근 권한이 거부되었습니다.';
          });
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _errorMessage = '위치 정보 접근 권한이 영구적으로 거부되었습니다.';
        });
      }
      return null;
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  }

  Future<void> _loadWeatherData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null; // 이전 에러 메시지 초기화
    });

    Position? position = await _determinePosition();
    if (position == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // _errorMessage는 _determinePosition 내부에서 설정됨
        });
      }
      return;
    }

    double latitude = position.latitude;
    double longitude = position.longitude;

    try {
      final weatherUri = Uri.parse('$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_weatherApiKey&lang=kr&units=metric');
      final airPollutionUri = Uri.parse('$_baseUrl/air_pollution?lat=$latitude&lon=$longitude&appid=$_weatherApiKey');

      // Future.wait를 사용하여 두 API를 동시에 호출
      final responses = await Future.wait([
        http.get(weatherUri).timeout(const Duration(seconds: 10)), // 타임아웃 추가
        http.get(airPollutionUri).timeout(const Duration(seconds: 10)),
      ]);

      WeatherDataModel? newWeatherData;
      AirPollutionDataModel? newAirPollutionData;

      if (responses[0].statusCode == 200) {
        newWeatherData = WeatherDataModel.fromJson(jsonDecode(responses[0].body));
      } else {
        throw Exception('날씨 정보 로드 실패: ${responses[0].statusCode}');
      }

      if (responses[1].statusCode == 200) {
        newAirPollutionData = AirPollutionDataModel.fromJson(jsonDecode(responses[1].body));
      } else {
        throw Exception('대기오염 정보 로드 실패: ${responses[1].statusCode}');
      }

      if (mounted) {
        setState(() {
          _weatherData = newWeatherData;
          _airPollutionData = newAirPollutionData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '데이터 로딩 중 오류 발생: $e';
          _isLoading = false;
        });
      }
      debugPrint("[HomeWeatherWidget_ERROR] $e");
    }
  }

  String _getPmStatus(double value, bool isPm10) {
    if (isPm10) {
      if (value <= 30) return '좋음';
      if (value <= 80) return '보통';
      if (value <= 150) return '나쁨';
      return '매우 나쁨';
    } else {
      if (value <= 15) return '좋음';
      if (value <= 50) return '보통';
      if (value <= 100) return '나쁨';
      return '매우 나쁨';
    }
  }

  String _getOverallAirQualityStatus() {
    if (_airPollutionData == null || _airPollutionData!.list.isEmpty) {
      return '정보 없음';
    }
    final components = _airPollutionData!.list[0].components;
    String pm10Status = _getPmStatus(components.pm10, true);
    String pm25Status = _getPmStatus(components.pm2_5, false);

    if (pm10Status == '매우 나쁨' || pm25Status == '매우 나쁨') return '매우 나쁨';
    if (pm10Status == '나쁨' || pm25Status == '나쁨') return '나쁨';
    if (pm10Status == '보통' || pm25Status == '보통') return '보통';
    return '좋음';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: SizedBox(
            width: 20, height: 20, // 로딩 인디케이터 크기 조절
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                  ),
                  // 새로고침 버튼 추가 (선택 사항)
                  // TextButton(onPressed: _loadWeatherData, child: Text("재시도"))
                ]),
          ),
        ),
      );
    }

    if (_weatherData == null || _weatherData!.weather.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, color: Colors.grey, size: 30),
              SizedBox(height: 4),
              Text('날씨 정보 없음', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    String airQualityDisplayStatus = "대기: 정보 없음";
    if (_airPollutionData != null && _airPollutionData!.list.isNotEmpty) {
      airQualityDisplayStatus = "대기: ${_getOverallAirQualityStatus()}";
    }

    String weatherIconCode = _weatherData!.weather[0].icon;
    String temperature = '${_weatherData!.main.temp.round()}°C';

    return Expanded(
      child: Center(
        child: Transform.translate( // Stack 전체를 Y축으로 이동시키기 위해 Transform.translate 사용
          offset: const Offset(0, -15.0), // Y축으로 -15만큼 이동 (위로 15 logical pixels 이동)
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // 1. 배경 이미지
              Image.network(
                'https://openweathermap.org/img/wn/$weatherIconCode@2x.png',
                width: 115,
                height: 115,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // 에러 발생 시에도 동일한 크기를 유지하고 아이콘 표시
                  return Container(
                    width: 115,
                    height: 115,
                    child: const Center(
                      child: Icon(Icons.cloud_off_outlined, size: 40, color: Colors.grey),
                    ),
                  );
                },
              ),

              // 2. 이미지 위에 표시될 텍스트 (하단 정렬)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        temperature,
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          airQualityDisplayStatus,
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}