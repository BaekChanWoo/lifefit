import 'package:flutter/material.dart';
import '../model/weather_model.dart'; // WeatherDataModel, AirPollutionDataModel, FiveDayForecastModel 등이 정의되어 있다고 가정합니다.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  WeatherDataModel? weatherData;
  AirPollutionDataModel? airPollutionData;
  FiveDayForecastModel? fiveDayForecastData;
  final String weatherApiKey = '661900b7652cefedb11f6e2ddd2b0daa'; // 실제 API 키를 사용하세요.
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

    // 서울의 위도와 경도 (예시)
    const double latitude = 37.5665;
    const double longitude = 126.9780;

    weatherData = await fetchWeatherData("Seoul"); // 현재 날씨 (도시 이름 기반)
    airPollutionData = await fetchAirPollutionData(latitude, longitude);
    fiveDayForecastData = await fetchFiveDayForecastData(latitude, longitude);

    setState(() {
      isLoading = false;
    });
  }

  Future<WeatherDataModel?> fetchWeatherData(String cityName) async {
    final Uri url = Uri.parse(
        '$baseUrl/weather?q=$cityName&appid=$weatherApiKey&lang=kr&units=metric');
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

  Future<FiveDayForecastModel?> fetchFiveDayForecastData(
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

  void _showError(String message) {
    if (mounted) { // 위젯이 여전히 마운트된 상태인지 확인
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
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
    if (pm25 <= 50) return '보통'; // PM2.5 '보통' 기준치 수정 (환경부 기준과 유사하게)
    if (pm25 <= 100) return '나쁨'; // PM2.5 '나쁨' 기준치 수정 (환경부 기준과 유사하게)
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
        return 'assets/img/weather_normal.png'; // 기본 이미지 (또는 정보 없음 이미지)
    }
  }

  // 새로 추가된 도우미 함수 1: 전반적인 표시 정보 결정
  Map<String, String> _getOverallDisplayInfo() {
    if (airPollutionData == null) {
      return {
        'status': '정보 없음',
        'iconPath': _getAirQualityImagePath('보통'), // 기본 아이콘
        'message': '대기 정보를 가져올 수 없습니다.'
      };
    }

    String pm10Status = _getPm10Status(airPollutionData!.list[0].components.pm10);
    String pm25Status = _getPm25Status(airPollutionData!.list[0].components.pm2_5);
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

    return {
      'status': overallAirQualityStatus,
      'iconPath': iconPath,
      'message': message,
    };
  }

  // 새로 추가된 도우미 함수 2: 상태에 따른 색상 결정
  Color _getStatusColor(String status) {
    switch (status) {
      case '좋음':
        return const Color(0xFF00A95C); // 초록색 계열
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text(
            '날씨 정보', // AppBar 제목 수정
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // AppBar 그림자 제거 (선택 사항)
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87), // 아이콘 색상 변경 (선택 사항)
            onPressed: _loadWeatherData,
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : weatherData == null // weatherData가 null인 경우 먼저 확인
            ? const Text('날씨 정보를 가져올 수 없습니다. 새로고침 해주세요.')
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // 카드 상단 여백
                _buildWeatherCard1(), // 수정된 날씨 카드 1
                const SizedBox(height: 20),
                if (fiveDayForecastData != null) // 5일 예보 데이터가 있을 경우에만 표시
                  _buildWeatherCard2(), // 5일 예보 카드
                const SizedBox(height: 20), // 카드 하단 여백
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 수정된 _buildWeatherCard1 위젯
  Widget _buildWeatherCard1() {
    final overallDisplayInfo = _getOverallDisplayInfo();

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // 모서리 둥글기 증가
      ),
      color: Colors.white, // 카드 배경색 명시
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              // weatherData가 null이 아님은 build 메소드에서 이미 확인됨
              '${weatherData!.name}, ${weatherData!.sys.country}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            Image.asset(
              overallDisplayInfo['iconPath']!,
              width: 100,
              height: 100,
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

            // 상세 정보 (미세먼지, 초미세먼지, 현재 날씨)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // 각 Column의 상단 정렬
              children: [
                // 미세먼지 Column (Expanded로 감싸서 공간 균등 배분)
                Expanded(
                  child: Column(
                    children: [
                      const Text('미세먼지', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8), // 아이콘과 제목 사이 간격
                      if (airPollutionData != null && airPollutionData!.list.isNotEmpty) ...[
                        Image.asset(
                          _getAirQualityImagePath(_getPm10Status(airPollutionData!.list[0].components.pm10)),
                          width: 50, height: 50,
                        ),
                        const SizedBox(height: 8),
                        Text('${airPollutionData!.list[0].components.pm10.round()} ㎍/㎥', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text(_getPm10Status(airPollutionData!.list[0].components.pm10), style: TextStyle(fontSize: 13, color: _getStatusColor(_getPm10Status(airPollutionData!.list[0].components.pm10)))),
                      ] else ...[
                        // 데이터 없을 시 표시 (높이 유지를 위해 아이콘 공간만큼 빈 공간 추가 고려 가능)
                        const SizedBox(height: 50 + 8 + 13 + 2 + 13), // 대략적인 컨텐츠 높이
                        const Center(child: Text('정보 없음', style: TextStyle(fontSize: 13, color: Colors.grey))),
                      ],
                    ],
                  ),
                ),

                // 초미세먼지 Column (Expanded로 감싸서 공간 균등 배분)
                Expanded(
                  child: Column(
                    children: [
                      const Text('초미세먼지', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      if (airPollutionData != null && airPollutionData!.list.isNotEmpty) ...[
                        Image.asset(
                          _getAirQualityImagePath(_getPm25Status(airPollutionData!.list[0].components.pm2_5)),
                          width: 50, height: 50,
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

                // 현재 날씨 Column (Expanded로 감싸서 공간 균등 배분)
                Expanded(
                  child: Column(
                    children: [
                      const Text('현재 날씨', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      // weatherData는 _buildWeatherCard1이 호출될 때 null이 아님이 상위에서 체크된다고 가정
                      if (weatherData != null && weatherData!.weather.isNotEmpty) ...[
                        Image.network(
                          'https://openweathermap.org/img/wn/${weatherData!.weather[0].icon}@2x.png',
                          width: 50, height: 50,
                          errorBuilder: (context, error, stackTrace) => const Tooltip(
                            message: '날씨 아이콘 로딩 실패',
                            child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${weatherData!.main.temp.round()}°C', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text(weatherData!.weather[0].description, style: const TextStyle(fontSize: 13, color: Colors.black87), textAlign: TextAlign.center),
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
    if (fiveDayForecastData == null || fiveDayForecastData!.list.isEmpty) {
      return Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text('5일 예보 정보를 가져올 수 없습니다.')),
        ),
      );
    }

    DateTime now = DateTime.now();
    List<ForecastItem> hourlyDisplayForecasts = [];

    // 현재 시간을 기준으로 표시할 예보의 시작 시간 결정
    int currentHour = now.hour;
    // 현재 시간이 속한 3시간 단위 슬롯의 시작 시간 (예: 13시 -> 12시, 14시 -> 12시)
    int slotStartHour = (currentHour ~/ 3) * 3;

    int targetHourForFiltering;
    DateTime targetDate = DateTime(now.year, now.month, now.day);

    // 사용자의 규칙 적용:
    // 현재 시간이 3시간 슬롯의 마지막 시간(slotStartHour + 2)에 해당하면, 다음 슬롯부터 표시
    // 그렇지 않으면 현재 슬롯부터 표시
    if (currentHour == slotStartHour + 2) {
      targetHourForFiltering = slotStartHour + 3;
    } else {
      targetHourForFiltering = slotStartHour;
    }

    // targetHourForFiltering이 24시 이상이면 다음 날로 처리
    if (targetHourForFiltering >= 24) {
      targetHourForFiltering -= 24;
      targetDate = targetDate.add(const Duration(days: 1));
    }

    // 필터링 시작 기준이 될 DateTime 객체 생성
    DateTime targetDateTimeForFilteringStart = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      targetHourForFiltering,
    );

    // 결정된 시작 시간 이후의 예보 5개를 hourlyDisplayForecasts 리스트에 추가
    if (fiveDayForecastData != null && fiveDayForecastData!.list.isNotEmpty) {
      for (var item in fiveDayForecastData!.list) {
        DateTime itemTimeLocal = DateTime.fromMillisecondsSinceEpoch(item.dt * 1000).toLocal();
        // itemTimeLocal이 targetDateTimeForFilteringStart 이후인지 확인
        if (!itemTimeLocal.isBefore(targetDateTimeForFilteringStart)) {
          if (hourlyDisplayForecasts.length < 5) {
            hourlyDisplayForecasts.add(item);
          } else {
            break; // 5개 항목을 모두 모았으면 중단
          }
        }
      }
    }

    // "이후 예보" (다음 날부터의 예보)를 위한 데이터 준비
    // 기존 로직을 활용하되, 오늘 날짜를 명확히 정의
    String todayDateString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map<String, List<ForecastItem>> subsequentForecasts = {};

    if (fiveDayForecastData != null && fiveDayForecastData!.list.isNotEmpty) {
      for (var item in fiveDayForecastData!.list) {
        String itemDateStr = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(item.dt * 1000));
        // 오늘 날짜가 아닌 경우에만 subsequentForecasts에 추가
        if (itemDateStr != todayDateString) {
          if (!subsequentForecasts.containsKey(itemDateStr)) {
            subsequentForecasts[itemDateStr] = [];
          }
          // 이후 예보는 날짜별로 UI가 너무 길어지지 않도록, 예를 들어 하루 최대 4개 항목만 추가 (선택 사항)
          if (subsequentForecasts[itemDateStr]!.length < 4) {
            subsequentForecasts[itemDateStr]!.add(item);
          }
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
            // 시간별 예보 섹션 (기존 "금일 예보" 대체)
            const Text(
              '시간별 예보', // 제목 변경
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
                children: hourlyDisplayForecasts.map((item) { // todayForecast 대신 hourlyDisplayForecasts 사용
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Column(
                      children: [
                        Text(
                            DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(item.dt * 1000).toLocal()), // Local time
                            style: const TextStyle(fontSize: 13)
                        ),
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

            // 이후 예보 섹션 (기존 로직 유지, 데이터 소스는 위에서 재구성된 subsequentForecasts)
            const Text(
              '이후 예보', // "주간 예보" 또는 "날짜별 예보" 등으로 변경 가능
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
                  ForecastItem representativeForecast = dailyForecasts.first; // 각 날짜의 대표 예보(첫번째 항목)

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
