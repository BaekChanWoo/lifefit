import 'package:flutter/material.dart';

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  // 미세먼지 날씨 테스트 이미지 에셋 경로
  final String weathertest1Image = 'assets/img/weathertest1.png';
  final String weathertest2Image = 'assets/img/weathertest2.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(
            child: Text(
              '미세먼지/날씨',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            IconButton(icon: Icon(Icons.menu), onPressed: () {}), // 메뉴...
          ],
        ), // 상단 GNB

        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 위치 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on),
                      Text('서울시 구로구', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  SizedBox(height: 20),

                  // 아이콘 및 상태 텍스트 섹션
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Image.asset(
                          weathertest1Image,
                          width: 166.0,
                          height: 166.0,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 6),
                        Text(
                          '좋음',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text('쾌적한 야외 활동을 즐기세요.'),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // 미세먼지/날씨 정보 섹션
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            weathertest1Image,
                            width: 60.0,
                            height: 60.0,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text('미세먼지',style: TextStyle(
                              fontSize: 15)),
                          Text('500㎍/m³',style: TextStyle(
                              fontSize: 15)),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            weathertest1Image,
                            width: 60.0,
                            height: 60.0,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text('초미세먼지',style: TextStyle(
                              fontSize: 15)),
                          Text('500㎍/m³',style: TextStyle(
                              fontSize: 15)),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            weathertest2Image,
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text('맑음/20도',style: TextStyle(
                              fontSize: 15), ),
                          Text('20%',style: TextStyle(
                              fontSize: 15), ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // 시간별 날씨
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('시간별 날씨',
                        style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ),
                  _buildWeatherTimeRow(),
                  SizedBox(height: 20),

                  // 주간 날씨
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('주간 날씨',
                        style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ),
                  _buildWeatherDayRow(),
                  SizedBox(height: 20),

                  // 대기 정보
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('대기 상태',
                        style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ),
                  _buildAirInfoRow(),
                ],
              ),
            ),
          ),
        ));
  }

  // 시간별 날씨 정보 섹션
  Widget _buildWeatherTimeRow() {
    // 데이터 리스트
    List<Map<String, String>> weatherDatatime = [
      {
        'time': '24시',
        'temperature': '6/-3도',
        'precipitation': '20%',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'time': '1시',
        'temperature': '6/-3도',
        'precipitation': '20%',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'time': '2시',
        'temperature': '6/-3도',
        'precipitation': '20%',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'time': '3시',
        'temperature': '6/-3도',
        'precipitation': '20%',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'time': '4시',
        'temperature': '6/-3도',
        'precipitation': '20%',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'time': '5시',
        'temperature': '6/-3도',
        'precipitation': '20%',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'time': '6시',
        'temperature': '6/-3도',
        'precipitation': '20%',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'time': '7시',
        'temperature': '6/-3도',
        'precipitation': '20%',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'time': '8시',
        'temperature': '6/-3도',
        'precipitation': '20%',
        'image': 'assets/img/weathertest2.png'
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weatherDatatime.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            // 각 아이템 간 간격 설정
            child: Column(
              children: [
                Text(weatherDatatime[index]['time']!),
                SizedBox(height: 6.0),
                Image.asset(
                  weatherDatatime[index]['image']!,
                  width: 46,
                  height: 46,
                ),
                SizedBox(height: 6.0),
                Text(weatherDatatime[index]['temperature']!),
                Text(weatherDatatime[index]['precipitation']!),
              ],
            ),
          );
        },
      ),
    );
  }

  // 일별 날씨 정보 섹션
  Widget _buildWeatherDayRow() {
    List<Map<String, String>> weatherDataday = [
      {
        'day': '일',
        'temperature': '6/-3도',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'day': '월',
        'temperature': '6/-3도',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'day': '화',
        'temperature': '6/-3도',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'day': '수',
        'temperature': '6/-3도',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'day': '목',
        'temperature': '6/-3도',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'day': '금',
        'temperature': '6/-3도',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'day': '토',
        'temperature': '6/-3도',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'day': '일',
        'temperature': '6/-3도',
        'image': 'assets/img/weathertest2.png'
      },
      {
        'day': '월',
        'temperature': '6/-3도',
        'image': 'assets/img/weathertest2.png'
      },
    ];
    return SizedBox(
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weatherDataday.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            // 각 아이템 간 간격 설정
            child: Column(
              children: [
                Image.asset(
                  weatherDataday[index]['image']!,
                  width: 46, // 이미지 너비 설정
                  height: 46, // 이미지 높이 설정
                ),
                SizedBox(height: 6.0),
                Text(weatherDataday[index]['day']!),
                Text(weatherDataday[index]['temperature']!),
              ],
            ),
          );
        },
      ),
    );
  }

  // 대기 정보 섹션
  Widget _buildAirInfoRow() {
    List<Map<String, String>> AirInfo = [
      {
        'air': '이산화탄소',
        'condition': '좋음',
        'image': 'assets/img/weathertest1.png'
      },
      {
        'air': '일산화탄소',
        'condition': '좋음',
        'image': 'assets/img/weathertest1.png'
      },
      {'air': '오존', 'condition': '나쁨', 'image': 'assets/img/weathertest1.png'},
      {'air': '습도', 'condition': '10%', 'image': 'assets/img/weathertest1.png'},

      // ... 필요한 만큼 데이터 추가
    ];
    return SizedBox(
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AirInfo.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            // 각 아이템 간 간격 설정
            child: Column(
              children: [
                Image.asset(
                  AirInfo[index]['image']!,
                  width: 46, // 이미지 너비 설정
                  height: 46, // 이미지 높이 설정
                ),
                SizedBox(height: 6.0),
                Text(AirInfo[index]['air']!),
                Text(AirInfo[index]['condition']!),
              ],
            ),
          );
        },
      ),
    );
  }
}
