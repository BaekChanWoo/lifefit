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

  // 미세먼지 정보 데이터 리스트
  final List<Map<String, String>> dustInfoList = [
    {
      'air': '미세먼지',
      'condition': '500㎍/m³',
      'image': 'assets/img/weathertest1.png',
    },
    {
      'air': '초미세먼지',
      'condition': '500㎍/m³',
      'image': 'assets/img/weathertest1.png',
    },
  ];

  // 날씨 정보 데이터 리스트
  final List<Map<String, String>> weatherInfoList = [
    {
      'air': '맑음/20도',
      'condition': '20%',
      'image': 'assets/img/weathertest2.png',
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text(
            '미세먼지/날씨',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 메인 카드
            Card(
              elevation: 4.0, // 그림자 깊이
              shadowColor: Colors.greenAccent.withValues(alpha: 0.5), // 그림자 색상 및 투명도 조절
              shape: RoundedRectangleBorder( // 카드 모양 설정 (선택 사항)
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 위치 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on),
                        const Text('서울시 구로구', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 큰 아이콘 및 상태 텍스트 섹션
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
                          const SizedBox(height: 6),
                          Text(
                            '좋음',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text('쾌적한 야외 활동을 즐기세요.', style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 미세먼지/날씨 정보 섹션
                    Row(
                      children: [
                        for (var data in dustInfoList)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 패딩 조절
                              child: _buildInfoColumn(
                                data['image']!,
                                data['air']!,
                                data['condition']!,
                                60,
                              ),
                            ),
                          ),
                        for (var data in weatherInfoList)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 패딩 조절
                              child: _buildInfoColumn(
                                data['image']!,
                                data['air']!,
                                data['condition']!,
                                50,
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 하단 추가 정보 카드
            Card(
              elevation: 4.0, // 그림자 깊이
              shadowColor: Colors.greenAccent.withValues(alpha: 0.5), // 그림자 색상 및 투명도 조절
              shape: RoundedRectangleBorder( // 카드 모양 설정 (선택 사항)
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 시간별 날씨
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('시간별 날씨',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ),
                    _buildWeatherTimeRow(),
                    const SizedBox(height: 20),

                    // 주간 날씨
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('주간 날씨',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ),
                    _buildWeatherDayRow(),
                    const SizedBox(height: 20),

                    // 대기 정보
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('대기 상태',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ),
                    _buildAirInfoRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 공통 정보 Column 위젯
  Widget _buildInfoColumn(String imagePath, String title, String value,
      double imageSize) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
            child: Column(
              children: [
                Text(weatherDatatime[index]['time']!),
                const SizedBox(height: 6.0),
                Image.asset(
                  weatherDatatime[index]['image']!,
                  width: 46,
                  height: 46,
                ),
                const SizedBox(height: 6.0),
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
            child: Column(
              children: [
                Text(weatherDataday[index]['day']!),
                const SizedBox(height: 6.0),
                Image.asset(
                  weatherDataday[index]['image']!,
                  width: 46,
                  height: 46,
                ),
                const SizedBox(height: 6.0),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: AirInfo.map((data) =>
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    data['image']!,
                    width: 46,
                    height: 46,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    data['air']!,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    data['condition']!,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
        ).toList(),
      ),
    );
  }
}