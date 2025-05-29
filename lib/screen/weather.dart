import 'package:flutter/material.dart';
import '../model/weather_model.dart'; // 사용자 정의 모델 파일
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  WeatherDataModel? weatherData;
  AirPollutionDataModel? airPollutionData;
  FiveDayForecastModel? fiveDayForecastData;
  final String weatherApiKey = '661900b7652cefedb11f6e2ddd2b0daa'; // << 중요: 본인의 OpenWeatherMap API 키를 입력하세요!
  final String baseUrl = 'http://api.openweathermap.org/data/2.5';
  bool isLoading = true;
  String? _displayedLocationName; // UI에 표시될 최종 지역 이름

  @override
  void initState() {
    super.initState();
    print("[DEBUG] initState called, starting _loadWeatherDataForCurrentLocation...");
    _loadWeatherDataForCurrentLocation(); // 함수 이름 변경
  }

  Future<Position?> _determinePosition() async {
    print("[DEBUG] _determinePosition called");
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('[DEBUG] Location service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      if (mounted) {
        _showError('위치 서비스가 비활성화되어 있습니다. 설정을 확인해주세요.');
      }
      print('[DEBUG] Location service disabled, returning null');
      return null;
    }

    permission = await Geolocator.checkPermission();
    print('[DEBUG] Location permission status: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('[DEBUG] Requested permission, new status: $permission');
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showError('위치 정보 접근 권한이 거부되었습니다.');
        }
        print('[DEBUG] Location permission denied, returning null');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showError('위치 정보 접근 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.');
      }
      print('[DEBUG] Location permission denied forever, returning null');
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('[DEBUG] Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('[DEBUG] Error getting current position: $e');
      if (mounted) {
        _showError('현재 위치를 가져오는 데 실패했습니다: $e');
      }
      return null;
    }
  }

  Future<void> _loadWeatherDataForCurrentLocation() async {
    print("[DEBUG] _loadWeatherDataForCurrentLocation called");
    if (!mounted) {
      print("[DEBUG] _loadWeatherDataForCurrentLocation: Widget not mounted, exiting.");
      return;
    }
    setState(() {
      isLoading = true;
      // 위치를 가져오기 전이므로, 이전 _displayedLocationName을 유지하거나 초기 메시지 설정
      // _displayedLocationName = "현재 위치 확인 중..."; // 필요하다면
      print("[DEBUG] _loadWeatherDataForCurrentLocation: isLoading set to true");
    });

    Position? position = await _determinePosition();
    print('[DEBUG] _loadWeatherDataForCurrentLocation: Determined position is $position');

    if (position != null) {
      double latitude = position.latitude;
      double longitude = position.longitude;

      String weatherUrl = '$baseUrl/weather?lat=$latitude&lon=$longitude&appid=$weatherApiKey&lang=kr&units=metric';
      String airPollutionUrl = '$baseUrl/air_pollution?lat=$latitude&lon=$longitude&appid=$weatherApiKey';
      String forecastUrl = '$baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$weatherApiKey&lang=kr&units=metric';

      print('[DEBUG] Fetching Weather from: $weatherUrl');
      print('[DEBUG] Fetching Air Pollution from: $airPollutionUrl');
      print('[DEBUG] Fetching 5-Day Forecast from: $forecastUrl');

      final results = await Future.wait([
        fetchWeatherData(latitude, longitude),
        fetchAirPollutionData(latitude, longitude),
        fetchFiveDayForecastData(latitude, longitude),
      ]).catchError((e) {
        print("[DEBUG] Error during Future.wait: $e");
        if (mounted) {
          _showError("데이터를 가져오는 중 오류가 발생했습니다: $e");
          setState(() {
            weatherData = null;
            airPollutionData = null;
            fiveDayForecastData = null;
            _displayedLocationName = "데이터 로드 실패";
            isLoading = false;
            print("[DEBUG] _loadWeatherDataForCurrentLocation: Error in Future.wait, isLoading set to false.");
          });
        }
        return [null, null, null]; // 오류 발생 시 null 리스트 반환
      });

      print('[DEBUG] _loadWeatherDataForCurrentLocation: API call results - weatherData is null? ${results[0] == null}, airPollutionData is null? ${results[1] == null}, fiveDayForecastData is null? ${results[2] == null}');

      if (mounted) {
        setState(() {
          weatherData = results[0] as WeatherDataModel?;
          airPollutionData = results[1] as AirPollutionDataModel?;
          fiveDayForecastData = results[2] as FiveDayForecastModel?;

          if (weatherData != null && weatherData!.name.isNotEmpty) {
            _displayedLocationName = '${weatherData!.name}, ${weatherData!.sys.country}';
            print("[DEBUG] _loadWeatherDataForCurrentLocation: API weatherData.name is '${weatherData!.name}'. _displayedLocationName set to '$_displayedLocationName'.");
          } else if (weatherData != null && weatherData!.coord != null) { // API에서 도시 이름(name)이 안 올 경우 좌표로 표시
            _displayedLocationName = '현재 위치 (${weatherData!.coord!.lat.toStringAsFixed(2)}, ${weatherData!.coord!.lon.toStringAsFixed(2)})';
            print("[DEBUG] _loadWeatherDataForCurrentLocation: API weatherData.name is empty. _displayedLocationName set to '$_displayedLocationName' using coordinates.");
          }
          else {
            _displayedLocationName = '위치 정보 없음'; // 이것도 position이 null일 때와 구분 필요
            print("[DEBUG] _loadWeatherDataForCurrentLocation: No specific location name from API. _displayedLocationName set to '위치 정보 없음'.");
          }
          isLoading = false;
          print("[DEBUG] _loadWeatherDataForCurrentLocation: Fetched data, isLoading set to false.");
        });
      }
    } else {
      // 위치 정보를 가져오지 못한 경우
      if (mounted) {
        setState(() {
          _displayedLocationName = '위치를 가져올 수 없음';
          weatherData = null;
          airPollutionData = null;
          fiveDayForecastData = null;
          isLoading = false;
          print("[DEBUG] _loadWeatherDataForCurrentLocation: Position is null, isLoading set to false. _displayedLocationName set to '$_displayedLocationName'.");
        });
        // _showError("현재 위치를 확인할 수 없습니다. 위치 서비스 및 권한을 확인해주세요."); // _determinePosition에서 이미 처리할 수 있음
      }
    }
  }

  Future<WeatherDataModel?> fetchWeatherData(double latitude, double longitude) async {
    final Uri url = Uri.parse(
        '$baseUrl/weather?lat=$latitude&lon=$longitude&appid=$weatherApiKey&lang=kr&units=metric');
    // print('[DEBUG] fetchWeatherData URL: $url'); // 호출부에서 이미 출력
    try {
      final response = await http.get(url);
      print('[DEBUG] fetchWeatherData for ($latitude, $longitude) - Status Code: ${response.statusCode}');
      // print('[DEBUG] fetchWeatherData Body: ${response.body}'); // 너무 길어서 주석 처리, 필요시 해제
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return WeatherDataModel.fromJson(json);
      } else {
        if (mounted) _showError('날씨 정보 로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[DEBUG] fetchWeatherData Error: $e');
      if (mounted) _showError('날씨 정보 로드 오류: $e');
      return null;
    }
  }

  Future<AirPollutionDataModel?> fetchAirPollutionData(double latitude, double longitude) async {
    final Uri url = Uri.parse(
        '$baseUrl/air_pollution?lat=$latitude&lon=$longitude&appid=$weatherApiKey');
    // print('[DEBUG] fetchAirPollutionData URL: $url');
    try {
      final response = await http.get(url);
      print('[DEBUG] fetchAirPollutionData for ($latitude, $longitude) - Status Code: ${response.statusCode}');
      // print('[DEBUG] fetchAirPollutionData Body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return AirPollutionDataModel.fromJson(json);
      } else {
        if (mounted) _showError('대기 정보 로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[DEBUG] fetchAirPollutionData Error: $e');
      if (mounted) _showError('대기 정보 로드 오류: $e');
      return null;
    }
  }

  Future<FiveDayForecastModel?> fetchFiveDayForecastData(double latitude, double longitude) async {
    final Uri url = Uri.parse(
        '$baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$weatherApiKey&lang=kr&units=metric');
    // print('[DEBUG] fetchFiveDayForecastData URL: $url');
    try {
      final response = await http.get(url);
      print('[DEBUG] fetchFiveDayForecastData for ($latitude, $longitude) - Status Code: ${response.statusCode}');
      // print('[DEBUG] fetchFiveDayForecastData Body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return FiveDayForecastModel.fromJson(json);
      } else {
        if (mounted) _showError('5일 예보 로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[DEBUG] fetchFiveDayForecastData Error: $e');
      if (mounted) _showError('5일 예보 로드 오류: $e');
      return null;
    }
  }

  void _showError(String message) {
    print("[ERROR_MESSAGE_UI]: $message"); // UI 에러 메시지도 로그로 남김
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3), // 메시지 표시 시간
        ),
      );
    }
  }

  String _getPm10Status(double pm10) {
    if (pm10 <= 30) return '좋음';
    if (pm10 <= 80) return '보통';
    if (pm10 <= 150) return '나쁨';
    return '매우 나쁨';
  }

  String _getPm25Status(double pm25) {
    if (pm25 <= 15) return '좋음';
    if (pm25 <= 50) return '보통';
    if (pm25 <= 100) return '나쁨';
    return '매우 나쁨';
  }

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
        return 'assets/img/weather_normal.png';
    }
  }

  Map<String, String> _getOverallDisplayInfo() {
    if (airPollutionData == null || airPollutionData!.list.isEmpty) {
      // print("[DEBUG] _getOverallDisplayInfo: Air pollution data is null or empty.");
      return {
        'status': '정보 없음',
        'iconPath': _getAirQualityImagePath('보통'),
        'message': '대기 정보를 가져올 수 없습니다.'
      };
    }

    final components = airPollutionData!.list[0].components;
    String pm10Status = _getPm10Status(components.pm10);
    String pm25Status = _getPm25Status(components.pm2_5);
    String overallAirQualityStatus;

    if (pm10Status == '매우 나쁨' || pm25Status == '매우 나쁨') {
      overallAirQualityStatus = '매우 나쁨';
    } else if (pm10Status == '나쁨' || pm25Status == '나쁨') {
      overallAirQualityStatus = '나쁨';
    } else if (pm10Status == '보통' || pm25Status == '보통') {
      overallAirQualityStatus = '보통';
    } else {
      overallAirQualityStatus = '좋음';
    }

    String iconPath = _getAirQualityImagePath(overallAirQualityStatus);
    String message;

    switch (overallAirQualityStatus) {
      case '좋음':
        message = '쾌적한 야외 활동을 즐기세요.';
        break;
      case '보통':
        message = '야외 활동에 무난한 상태입니다.';
        break;
      case '나쁨':
        message = '야외 활동 시 주의가 필요합니다.';
        break;
      case '매우 나쁨':
        message = '외출을 자제하고 실내에 머무르세요.';
        break;
      default:
        message = '대기 및 날씨 정보를 확인 중입니다.';
    }
    // print("[DEBUG] _getOverallDisplayInfo: Status - $overallAirQualityStatus, Icon - $iconPath, Message - $message");
    return {
      'status': overallAirQualityStatus,
      'iconPath': iconPath,
      'message': message,
    };
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '좋음':
        return const Color(0xFF00A95C);
      case '보통':
        return Colors.blueAccent;
      case '나쁨':
        return Colors.orange.shade700;
      case '매우 나쁨':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("[DEBUG] build called. isLoading: $isLoading, weatherData is null: ${weatherData == null}, _displayedLocationName: $_displayedLocationName");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text(
            '날씨 정보',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: (){
              print("[DEBUG] Refresh button pressed.");
              _loadWeatherDataForCurrentLocation();
            },
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Text(_displayedLocationName != null && _displayedLocationName!.isNotEmpty ? "$_displayedLocationName 날씨 로딩 중..." : "날씨 정보 로딩 중..."),
          ],
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildWeatherCard1(),
              const SizedBox(height: 20),
              _buildWeatherCard2(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard1() {
    // print("[DEBUG] _buildWeatherCard1 called. _displayedLocationName: $_displayedLocationName");
    final overallDisplayInfo = _getOverallDisplayInfo();

    if (weatherData == null && airPollutionData == null && !isLoading) {
      return Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞춤
            children: [
              Text(_displayedLocationName ?? '위치 정보 없음', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('날씨 및 대기 정보를 가져올 수 없습니다. 네트워크 연결, API 키, 위치 권한을 확인 후 새로고침 해주세요.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _displayedLocationName ?? '위치 분석 중...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Image.asset(
              overallDisplayInfo['iconPath']!,
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                print("[DEBUG_IMAGE_ERROR] Asset image load error for ${overallDisplayInfo['iconPath']}: $error");
                return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
              },
            ),
            const SizedBox(height: 10),
            Text(
              overallDisplayInfo['status']!,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(overallDisplayInfo['status']!),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                overallDisplayInfo['message']!,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('미세먼지', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      if (airPollutionData != null && airPollutionData!.list.isNotEmpty) ...[
                        Image.asset(
                          _getAirQualityImagePath(_getPm10Status(airPollutionData!.list[0].components.pm10)),
                          width: 50, height: 50,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text('${airPollutionData!.list[0].components.pm10.round()} ㎍/㎥', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text(_getPm10Status(airPollutionData!.list[0].components.pm10), style: TextStyle(fontSize: 13, color: _getStatusColor(_getPm10Status(airPollutionData!.list[0].components.pm10)))),
                      ] else ...[
                        const SizedBox(height: 50 + 8 + 13 + 2 + 13),
                        const Center(child: Text('정보 없음', style: TextStyle(fontSize: 13, color: Colors.grey))),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('초미세먼지', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      if (airPollutionData != null && airPollutionData!.list.isNotEmpty) ...[
                        Image.asset(
                          _getAirQualityImagePath(_getPm25Status(airPollutionData!.list[0].components.pm2_5)),
                          width: 50, height: 50,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text('${airPollutionData!.list[0].components.pm2_5.round()} ㎍/㎥', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text(_getPm25Status(airPollutionData!.list[0].components.pm2_5), style: TextStyle(fontSize: 13, color: _getStatusColor(_getPm25Status(airPollutionData!.list[0].components.pm2_5)))),
                      ] else ...[
                        const SizedBox(height: 50 + 8 + 13 + 2 + 13),
                        const Center(child: Text('정보 없음', style: TextStyle(fontSize: 13, color: Colors.grey))),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('현재 날씨', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      if (weatherData != null && weatherData!.weather.isNotEmpty) ...[
                        Image.network(
                          'https://openweathermap.org/img/wn/${weatherData!.weather[0].icon}@2x.png',
                          width: 50, height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            print("[DEBUG_IMAGE_ERROR] Network image load error for ${weatherData!.weather[0].icon}: $error");
                            return const Tooltip(
                              message: '날씨 아이콘 로딩 실패',
                              child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text('${weatherData!.main.temp.round()}°C', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 2),
                        //Text(weatherData!.weather[0].description, style: const TextStyle(fontSize: 13, color: Colors.black87), textAlign: TextAlign.center), 언어 제공 확인후 수정
                      ] else ...[
                        const SizedBox(height: 50 + 8 + 14 + 2 + 13),
                        const Center(child: Text('정보 없음', style: TextStyle(fontSize: 13, color: Colors.grey))),
                      ]
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard2() {
    // print("[DEBUG] _buildWeatherCard2 called. fiveDayForecastData is null: ${fiveDayForecastData == null}");
    if (fiveDayForecastData == null || fiveDayForecastData!.list.isEmpty) {
      return Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        color: Colors.white,
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text('5일 예보 정보를 가져올 수 없습니다.')),
        ),
      );
    }

    DateTime now = DateTime.now();
    List<ForecastItem> hourlyDisplayForecasts = [];
    int currentHour = now.hour;
    int slotStartHour = (currentHour ~/ 3) * 3;
    int targetHourForFiltering;
    DateTime targetDate = DateTime(now.year, now.month, now.day);

    if (currentHour == slotStartHour + 2) {
      targetHourForFiltering = slotStartHour + 3;
    } else {
      targetHourForFiltering = slotStartHour;
    }

    if (targetHourForFiltering >= 24) {
      targetHourForFiltering -= 24;
      targetDate = targetDate.add(const Duration(days: 1));
    }

    DateTime targetDateTimeForFilteringStart = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      targetHourForFiltering,
    );

    for (var item in fiveDayForecastData!.list) {
      DateTime itemTimeLocal = DateTime.fromMillisecondsSinceEpoch(item.dt * 1000).toLocal();
      if (!itemTimeLocal.isBefore(targetDateTimeForFilteringStart)) {
        if (hourlyDisplayForecasts.length < 5) {
          hourlyDisplayForecasts.add(item);
        } else {
          break;
        }
      }
    }

    String todayDateString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map<String, List<ForecastItem>> subsequentForecasts = {};

    for (var item in fiveDayForecastData!.list) {
      String itemDateStr = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(item.dt * 1000));
      if (itemDateStr != todayDateString) {
        if (!subsequentForecasts.containsKey(itemDateStr)) {
          subsequentForecasts[itemDateStr] = [];
        }
        if (subsequentForecasts[itemDateStr]!.length < 4) {
          subsequentForecasts[itemDateStr]!.add(item);
        }
      }
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '시간별 예보',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            hourlyDisplayForecasts.isEmpty
                ? const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text('시간별 예보 정보가 없습니다.', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ))
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: hourlyDisplayForecasts.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Column(
                      children: [
                        Text(
                            DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(item.dt * 1000).toLocal()),
                            style: const TextStyle(fontSize: 13)),
                        Image.network(
                          'https://openweathermap.org/img/wn/${item.weather[0].icon}@2x.png',
                          width: 45,
                          height: 45,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud_off, size: 45, color: Colors.grey),
                        ),
                        Text('${item.main.temp.round()}°C', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '이후 예보',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            subsequentForecasts.isEmpty
                ? const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text('이후 예보 정보가 없습니다.', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ))
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subsequentForecasts.entries.map((entry) {
                  String date = entry.key;
                  List<ForecastItem> dailyForecasts = entry.value;
                  ForecastItem representativeForecast = dailyForecasts.first;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MM/dd(E)', 'ko_KR').format(DateTime.parse(date)),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Image.network(
                          'https://openweathermap.org/img/wn/${representativeForecast.weather[0].icon}@2x.png',
                          width: 45,
                          height: 45,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud_off, size: 45, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text('${representativeForecast.main.temp.round()}°C', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}