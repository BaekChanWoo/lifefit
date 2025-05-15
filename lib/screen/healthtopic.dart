import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/news_model.dart';
import '../model/healthvideo_model.dart';
import '../model/realtimetopic_model.dart';
import 'package:url_launcher/url_launcher.dart';

class Healthtopic extends StatefulWidget {
  const Healthtopic({super.key});

  @override
  State<Healthtopic> createState() => _HealthtopicState();
}

class _HealthtopicState extends State<Healthtopic> {
  //데이터 리스트
  List<NewsArticle> _newsArticles = [];
  List<SearchResult> _youtubeVideos = [];

  // 테스트 이미지 에셋 경로
  final String test1Image = 'assets/img/test1.png';

  // 최상단 이미지 슬라이더/인디케이터 요소
  final List<int> pages = List.generate(4, (index) => index); //카드 인덱스
  final PageController controller = PageController(initialPage: 0); //카드 페이지 컨트롤러
  int curruntPage = 0; // 카드 페이지 정수

  //슬라이더 카운트
  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 7), (Timer timer) {
      if (controller.hasClients && controller.page != null) {
        if (controller.page! < _newsArticles.length - 1) { // Update list name
          controller.nextPage(
            duration: Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        } else {
          controller.animateToPage(
            0,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      }
    });

    _fetchData(); // newsdata.io 데이터 가져오기 (뉴스 슬라이더용)
    _fetchYoutubeVideos().then((videos) { // 유튜브 데이터 가져오기
      setState(() {
        _youtubeVideos = videos;
      });
    });
  }

  // 데이터 가져오기
  Future<void> _fetchData() async {
    try {
      final naverNews = await _fetchNaverNews();
      final newsDataIo = await _fetchNewsDataIo();

      setState(() {
        _newsArticles.clear(); // 기존 데이터 초기화
        _newsArticles.addAll(naverNews.cast<NewsArticle>());
        _newsArticles.addAll(newsDataIo);
        _newsArticles.sort((a, b) => b.pubDate.compareTo(a.pubDate)); // 최신순 정렬
      });
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  // 미사용시 컨트롤러 리소스해제
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 데이터 리스트 정의 (순차 삭제)
  final List<Map<String, dynamic>> mealRecommendations = [
    {
      'image': 'assets/img/test1.png',
      'title': '상큼한 샐러드 레시피',
      'recipe': 'XXX 레시피',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '건강한 스무디',
      'recipe': 'YYY 레시피',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '건강한 스무디',
      'recipe': 'YYY 레시피',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '건강한 스무디',
      'recipe': 'YYY 레시피',
    },
    // ... 더 많은 식사 추천 데이터
  ]; // 식사 추천

  // 공통 위젯 생성 함수 정의
  Widget _buildContentCard(Map<String, dynamic> data, String contentType , [int index = 0]) {
    switch (contentType) {
      case 'realTimeTopic'://실시간 토픽 섹션
        return Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container( // Image 대신 Container 사용
                decoration: BoxDecoration(
                  color: Colors.grey[300], // 컨테이너의 배경색
                  borderRadius: BorderRadius.circular(10.0), // 모든 모서리를 10.0의 반지름으로 둥글게 만듭니다.
                ),
                width: 90.0,
                height: 90.0,
                child: Center(
                  child: Text(
                    '${index + 1}', // 1, 2, 3, 4 숫자 표시
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'], style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis, maxLines: 2),
                    SizedBox(height: 8.0),
                    Text(data['description'], style: TextStyle(fontSize: 13.0),
                        overflow: TextOverflow.ellipsis, maxLines: 2),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'mealRecommendation': // 레시피 섹션
        return Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4.0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(data['image'], width: 154.0, height: 154.0, fit: BoxFit.cover),
                ),
                SizedBox(height: 8.0),
                Text(data['title'], textAlign: TextAlign.left),
                SizedBox(height: 8.0),
                Text(data['recipe']),
              ],
            ),
          ),
        );
      case 'videoContent': // 영상 섹션
        final videoId = data['videoId']; // videoId 추출
        // 썸네일 URL 선택 로직 수정
        final thumbnailUrl = data['mediumThumbnailUrl'] ?? data['highThumbnailUrl'] ?? data['defaultThumbnailUrl'];
        final title = data['title'];
        final channelTitle = data['channelTitle'];
        return Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          color: Colors.white,
          child: InkWell( // InkWell로 감싸서 터치 효과 추가
            onTap: () {
              _launchYoutubeVideo(videoId); // 유튜브 앱 실행 함수 호출
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network( // Image.network 사용
                        thumbnailUrl,
                        width: 290.0,
                        height: 164.0,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, object, stackTrace) {
                          return Center(child: Icon(Icons.error_outline));
                        },
                      ),
                    ),
                    Icon(Icons.play_circle_fill, color: Colors.white, size: 60.0),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 274.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis, maxLines: 2),
                        SizedBox(height: 8.0),
                        Text(channelTitle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return Container(); // 기본적으로 빈 컨테이너 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            '건강토픽',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.menu), onPressed: () {}), // 메뉴...
        ],
      ), // 상단 GNB

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20), // 마진
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //최상단 이미지 슬라이드 뉴스 (newsdata.io 적용)
            Container(
              width: double.infinity,
              height: 320,
              child: _newsArticles.isEmpty // Update list name
                  ? Center(child: CircularProgressIndicator())
                  : PageView.builder(
                controller: controller,
                itemCount: 4,  // _newsArticles.length > 4 ? 4 : _newsArticles.length, // Update list name
                onPageChanged: (page) {
                  setState(() {
                    curruntPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final article = _newsArticles[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: InkWell( // Use InkWell for tap effect
                      onTap: () async { //탭으로 웹 사이트로 이동
                        final Uri? _url = Uri.tryParse(article.link);
                        if (_url != null) {
                          try {
                            final bool launched = await launchUrl(_url);
                            if (!launched) {
                              print('Failed to launch URL: ${_url.toString()}');
                              // 사용자에게 알림
                            }
                          } catch (e) {
                            print('Error launching URL: $e');
                            // 사용자에게 에러 메시지 표시
                          }
                        } else {
                          print('Invalid URL: ${article.link}');
                          // 사용자에게 알림
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 4.0,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: article.imageUrl != null
                                  ? Image.network(
                                article.imageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, object, stackTrace) {
                                  return Center(child: Icon(Icons.error_outline));
                                },
                              )
                                  : Container(color: Colors.grey),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              right: 16,
                              child: Text(
                                article.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (num i = 0; i < 4; i++) // (num i = 0; i <(_newsArticles.length > 4 ? 4 : _newsArticles.length); i++) // Update list name
                  Container(
                    margin: EdgeInsets.all(3),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: curruntPage == i
                          ? Colors.blue
                          : Colors.grey.withValues(alpha: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 48.0),


            // 실시간 토픽 섹션 (newsdata.io 적용) 네이버 적용 예정
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('실시간 토픽',
                  style:
                  TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 564.0,
              child: FutureBuilder<List<ArticleItem>>( // FutureBuilder 사용
                future: _fetchNaverNews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final naverArticles = snapshot.data!;
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: naverArticles.length > 5 ? 5 : naverArticles.length,
                      itemBuilder: (context, index) {
                        final article = naverArticles[index];
                        return _buildContentCard(
                          {
                            'title': article.title,
                            'description': article.description,
                          },
                          'realTimeTopic',
                          index, // index 전달
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No data'));
                  }
                },
              ),
            ),
            SizedBox(height: 48.0),

            // 식사 추천 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('식사로 챙기는 건강!',
                  style:
                  TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 250.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mealRecommendations.length,
                itemBuilder: (context, index) {
                  return _buildContentCard(mealRecommendations[index], 'mealRecommendation');
                },
              ),
            ),
            SizedBox(height: 48.0),

            // 영상 섹션 (유튜브 적용)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('영상으로 보는 건강지식',
                  style:
                  TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 260.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _youtubeVideos.length,
                itemBuilder: (context, index) {
                  final video = _youtubeVideos[index];
                  return _buildContentCard(
                    {
                      'videoId': video.id.videoId,
                      'defaultThumbnailUrl': video.snippet.thumbnails.thumbnailDefault.url,
                      'mediumThumbnailUrl': video.snippet.thumbnails.medium?.url,
                      'highThumbnailUrl': video.snippet.thumbnails.high?.url,
                      'title': video.snippet.title,
                      'channelTitle': video.snippet.channelTitle,
                    },
                    'videoContent',
                  );
                },
              ),
            ),
            SizedBox(height: 48.0),

          ],
        ),
      ),
    );
  }
}

//  newsdata.io 데이터 가져오는 함수(카드 슬라이더 뉴스)
Future<List<NewsArticle>> _fetchNewsDataIo() async {
  final response = await http.get(Uri.parse('https://newsdata.io/api/1/news?country=kr&q=건강%20OR%20웰빙&apikey=pub_8514684c9e5ae1f3e898c8550491c72eebe05'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> decodedJson = json.decode(response.body);
    final List<dynamic> results = decodedJson['results'];
    final List<NewsArticle> newsArticles = results.map((json) => NewsArticle.fromJson(json)).toList();
    return newsArticles;
  } else {
    throw Exception('Failed to load news');
  }
}

// 네이버 검색 API 호출 및 데이터 모델 적용 (실시간 토픽 전용)
Future<List<ArticleItem>> _fetchNaverNews() async {
  final String clientId = 'E8ElLohbjuT1eaH79agX'; // Replace with your Naver Client ID
  final String clientSecret = 'PAqjeoE83U'; // Replace with your Naver Client Secret
  final String query = '건강 OR 웰빙'; // 검색어

  final Uri uri = Uri.parse('https://openapi.naver.com/v1/search/news.json?query=$query&display=5');

  final response = await http.get(
    uri,
    headers: {
      'X-Naver-Client-Id': clientId,
      'X-Naver-Client-Secret': clientSecret,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final SearchResponse searchResponse = SearchResponse.fromJson(jsonResponse);
    return searchResponse.items;
  } else {
    throw Exception('Failed to load Naver news: ${response.statusCode}');
  }
}

// 레시피 데이터 가져오는 함수
//Future<List<Map<String, dynamic>>> _fetchRecipeData() async {

//}
// 유튜브 건강 관련 영상 데이터 함수
Future<List<SearchResult>> _fetchYoutubeVideos() async {
  final String apiKey = 'AIzaSyBNFUaREtKTnkHmLNz7-tv2L9nv-E_PQxs'; // 여기에 실제 API 키를 넣으세요.
  final int maxResults = 5; // 가져올 영상 개수
  final String apiUrl = 'https://www.googleapis.com/youtube/v3/search?part=snippet&key=$apiKey&q=건강 관련 영상&maxResults=$maxResults&type=video';

  final Uri uri = Uri.parse(apiUrl);

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final SearchListResponse searchListResponse = SearchListResponse.fromJson(jsonResponse);
    return searchListResponse.items;
  } else {
    throw Exception('Failed to load youtube videos: ${response.statusCode}');
  }
}
// 유튜브 앱
_launchYoutubeVideo(String videoId) async {
  final Uri _url = Uri.parse('youtube://' + videoId);
  if (await canLaunchUrl(_url)) {
    await launchUrl(_url);
  } else {
    final Uri _webUrl = Uri.parse('https://www.youtube.com/watch?v=' + videoId); // 웹 URL
    if (await canLaunchUrl(_webUrl)) {
      await launchUrl(_webUrl);
    } else {
      throw 'Could not launch $videoId';
    }
  }
}
