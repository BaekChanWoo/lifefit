import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert'; // json.decode 및 utf8.decode 사용
import 'package:html_unescape/html_unescape.dart'; // HTML 엔티티 처리를 위해 추가
import 'package:url_launcher/url_launcher.dart';

// 외부 모델 파일 import (실제 프로젝트 구조에 맞게 경로 수정)
import '../model/news_model.dart'; // 사용자 정의 NewsArticle 모델 사용
import '../model/healthvideo_model.dart';
import '../model/realtimetopic_model.dart'; // Naver News 응답용 모델 포함 가정

class Healthtopic extends StatefulWidget {
  const Healthtopic({super.key});

  @override
  State<Healthtopic> createState() => _HealthtopicState();
}

class _HealthtopicState extends State<Healthtopic> {
  // 데이터 리스트
  List<NewsArticle> _newsSliderArticles = []; // 카드 슬라이더 뉴스
  List<SearchResult> _youtubeVideos = []; // 유튜브 영상

  // 최상단 이미지 슬라이더/인디케ATOR 요소
  final PageController controller = PageController(initialPage: 0); // 카드 페이지 컨트롤러
  int curruntPage = 0; // 현재 카드 페이지 인덱스

  // 실시간 토픽 데이터를 위한 Future 상태 변수
  Future<List<ArticleItem>>? _naverNewsFuture;

  // HTML 엔티티 변환기 인스턴스 (클래스 멤버로 한 번만 생성)
  final HtmlUnescape _unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();

    // 뉴스 슬라이더 자동 넘김 타이머
    Timer.periodic(Duration(seconds: 7), (Timer timer) {
      if (controller.hasClients && controller.page != null && _newsSliderArticles.isNotEmpty) {
        final int itemCount = _newsSliderArticles.length > 4 ? 4 : _newsSliderArticles.length;
        if (itemCount == 0) return; // 아이템이 없으면 동작 안 함
        final int nextPage = (controller.page!.round() + 1) % itemCount;
        controller.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });

    _fetchNewsSliderData(); // 카드 슬라이더 뉴스 데이터 가져오기
    _naverNewsFuture = _fetchNaverNews(); // 실시간 토픽 데이터 Future 초기화
    _fetchYoutubeVideos().then((videos) {
      if (mounted) { // 위젯이 여전히 마운트된 상태인지 확인
        setState(() {
          _youtubeVideos = videos;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // HTML 엔티티 변환 및 태그 제거를 위한 함수
  String cleanHtmlString(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) return '';

    // 1. HTML 엔티티를 일반 문자로 변환 (예: " -> ")
    var textWithoutEntities = _unescape.convert(htmlText);
    // 2. 남아있는 HTML 태그 제거 (예: <b>, <i> 등)
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return textWithoutEntities.replaceAll(exp, ''); // String 객체의 replaceAll 사용
  }

  // 카드 슬라이더 뉴스 데이터 가져오기 (Newsdata.io)
  Future<void> _fetchNewsSliderData() async {
    try {
      final newsDataIo = await _fetchNewsDataIoApi();
      if (mounted) {
        setState(() {
          _newsSliderArticles.clear();
          _newsSliderArticles.addAll(newsDataIo);

          // pubDate (String)를 DateTime으로 파싱하여 정렬 (최신순)
          _newsSliderArticles.sort((a, b) {
            // DateTime.tryParse를 사용하여 안전하게 파싱
            // a.pubDate와 b.pubDate는 모델에 따라 String 타입
            DateTime? dateA = DateTime.tryParse(a.pubDate);
            DateTime? dateB = DateTime.tryParse(b.pubDate);

            // 파싱 실패 또는 null일 경우를 대비한 기본값 설정
            DateTime fallbackDate = DateTime.fromMillisecondsSinceEpoch(0);

            // dateB와 dateA를 비교하여 내림차순 (최신 날짜가 먼저 오도록)
            return (dateB ?? fallbackDate).compareTo(dateA ?? fallbackDate);
          });
        });
      }
    } catch (e) {
      print('Error fetching news slider data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('슬라이더 뉴스를 불러오는데 실패했습니다.')),
        );
      }
    }
  }

  // 공통 위젯 생성 함수 정의
  Widget _buildContentCard(Map<String, dynamic> data, String contentType, [int index = 0]) {
    switch (contentType) {
      case 'realTimeTopic': //실시간 토픽 섹션
        final title = cleanHtmlString(data['title'] as String?);
        final link = data['link'] as String?;

        return Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () async {
              if (link != null && link.isNotEmpty) {
                final Uri? url = Uri.tryParse(link);
                if (url != null) {
                  _launchURL(url);
                } else {
                  print('Invalid URL format for realTimeTopic: $link');
                }
              } else {
                print('Empty or null URL for realTimeTopic');
              }
            },
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  width: 70.0,
                  height: 70.0,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isNotEmpty ? title : '제목 없음',
                        style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case 'videoContent': // 영상 섹션
        final videoId = data['videoId'] as String?;
        final thumbnailUrl = data['mediumThumbnailUrl'] as String? ?? data['highThumbnailUrl'] as String? ?? data['defaultThumbnailUrl'] as String?;
        final title = cleanHtmlString(data['title'] as String?);
        final channelTitle = cleanHtmlString(data['channelTitle'] as String?);

        return Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          color: Colors.white,
          child: InkWell(
            onTap: () {
              if (videoId != null && videoId.isNotEmpty) {
                _launchYoutubeVideo(videoId);
              } else {
                print('Video ID is null or empty');
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                          ? Image.network(
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
                          return Container(
                            width: 290.0,
                            height: 164.0,
                            color: Colors.grey[300],
                            child: Center(child: Icon(Icons.error_outline, color: Colors.grey[600], size: 40)),
                          );
                        },
                      )
                          : Container(
                        width: 290.0,
                        height: 164.0,
                        color: Colors.grey[300],
                        child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey[600], size: 40)),
                      ),
                    ),
                    Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.85), size: 60.0),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 274.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title.isNotEmpty ? title : '제목 없음',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis, maxLines: 2),
                        SizedBox(height: 8.0),
                        Text(channelTitle.isNotEmpty ? channelTitle : '채널 정보 없음',
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 슬라이더에 표시할 아이템 수 (최대 4개 또는 실제 아이템 수)
    final int sliderItemCount = _newsSliderArticles.isEmpty ? 0 : (_newsSliderArticles.length > 4 ? 4 : _newsSliderArticles.length);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            '건강토픽',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5, // 약간의 그림자 효과
        actions: [
          IconButton(icon: Icon(Icons.menu, color: Colors.black54), onPressed: () { /* 메뉴 기능 구현 */ }),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 최상단 이미지 슬라이드 뉴스
            if (sliderItemCount > 0) // 데이터가 있을 때만 슬라이더와 인디케이터 표시
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 320,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: sliderItemCount,
                      onPageChanged: (page) {
                        if (mounted) {
                          setState(() {
                            curruntPage = page;
                          });
                        }
                      },
                      itemBuilder: (context, index) {
                        final article = _newsSliderArticles[index];
                        final title = cleanHtmlString(article.title); // HTML 클리닝 적용
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: InkWell(
                            onTap: () async {
                              if (article.link.isNotEmpty) { // 모델에서 link는 non-nullable String
                                final Uri? url = Uri.tryParse(article.link);
                                if (url != null) {
                                  _launchURL(url);
                                } else {
                                  print('Invalid URL format for news slider: ${article.link}');
                                }
                              } else {
                                print('Empty URL for news slider article');
                              }
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              elevation: 4.0,
                              clipBehavior: Clip.antiAlias, // 이미지 잘림 방지
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                                    Image.network(
                                      article.imageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, object, stackTrace) {
                                        return Container(color: Colors.grey[300], child: Center(child: Icon(Icons.error_outline, color: Colors.grey[600])));
                                      },
                                    )
                                  else
                                    Container(color: Colors.grey[300], child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey[600]))),
                                  Positioned(
                                    left: 0,
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      child: Text(
                                        title.isNotEmpty ? title : '제목 없음',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                  // 인디케이터
                  if (sliderItemCount > 1) // 아이템이 2개 이상일 때만 인디케이터 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(sliderItemCount, (i) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          width: curruntPage == i ? 12 : 8,
                          height: curruntPage == i ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: curruntPage == i ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.5),
                          ),
                        );
                      }),
                    ),
                ],
              )
            else // 로딩 중 또는 데이터 없을 때 표시
              Container(
                height: 320,
                child: Center(child: _newsSliderArticles.isEmpty && !_fetchNewsSliderDataCompleted ? CircularProgressIndicator() : Text('뉴스가 없습니다.')),
              ),
            SizedBox(height: 48.0),

            // 실시간 토픽 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('실시간 토픽', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 432.0,
              child: FutureBuilder<List<ArticleItem>>(
                future: _naverNewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print('Error in FutureBuilder for Naver News: ${snapshot.error}');
                    return Center(child: Text('토픽을 불러오는데 실패했습니다.'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final naverArticles = snapshot.data!;
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: naverArticles.length > 5 ? 5 : naverArticles.length,
                      itemBuilder: (context, index) {
                        final article = naverArticles[index];
                        return _buildContentCard(
                          {
                            'title': article.title, // ArticleItem 모델의 title (String?)
                            'link': article.link,   // ArticleItem 모델의 link (String?)
                          },
                          'realTimeTopic',
                          index,
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('현재 실시간 토픽이 없습니다.'));
                  }
                },
              ),
            ),
            SizedBox(height: 48.0),

            // 영상 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('영상으로 보는 건강지식', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 260.0,
              child: _youtubeVideos.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _youtubeVideos.length,
                itemBuilder: (context, index) {
                  final video = _youtubeVideos[index];
                  return Padding(
                    padding: EdgeInsets.only(right: index == _youtubeVideos.length - 1 ? 0 : 10.0),
                    child: _buildContentCard(
                      {
                        'videoId': video.id.videoId,
                        'defaultThumbnailUrl': video.snippet.thumbnails.thumbnailDefault.url,
                        'mediumThumbnailUrl': video.snippet.thumbnails.medium?.url,
                        'highThumbnailUrl': video.snippet.thumbnails.high?.url,
                        'title': video.snippet.title,
                        'channelTitle': video.snippet.channelTitle,
                      },
                      'videoContent',
                    ),
                  );
                },
              )
                  : Center(child: _youtubeVideos.isEmpty && !_fetchYoutubeVideosCompleted ? CircularProgressIndicator() : Text('현재 영상이 없습니다.')),
            ),
            SizedBox(height: 48.0),
          ],
        ),
      ),
    );
  }

  // API 호출 완료 여부 플래그 (로딩 인디케이터 표시용 )
  bool _fetchNewsSliderDataCompleted = false;
  bool _fetchYoutubeVideosCompleted = false;


  // --- API 호출 함수들 ---
  Future<List<NewsArticle>> _fetchNewsDataIoApi() async {
    _fetchNewsSliderDataCompleted = false;
    const String apiKey = 'pub_8514684c9e5ae1f3e898c8550491c72eebe05';
    // 수정된 부분: (건강 OR 웰빙) 키워드를 포함하고, '정치' 키워드는 제외합니다.
    final String query = Uri.encodeComponent('(건강 OR 웰빙) NOT 정치');
    final Uri uri = Uri.parse('https://newsdata.io/api/1/news?country=kr&q=$query&language=ko&apikey=$apiKey');

    try {
      final response = await http.get(uri);
      _fetchNewsSliderDataCompleted = true;
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> results = decodedJson['results'] as List<dynamic>? ?? [];
        return results.map((jsonItem) => NewsArticle.fromJson(jsonItem as Map<String, dynamic>)).toList();
      } else {
        print('Failed to load news from newsdata.io: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load news from newsdata.io');
      }
    } catch (e) {
      _fetchNewsSliderDataCompleted = true;
      print('Error in _fetchNewsDataIoApi: $e');
      rethrow; // 에러를 다시 던져서 호출한 쪽에서 처리할 수 있도록 함
    }
  }

  Future<List<ArticleItem>> _fetchNaverNews() async {
    const String clientId = 'E8ElLohbjuT1eaH79agX';
    const String clientSecret = 'PAqjeoE83U';
    // 수정된 부분: '건강 뉴스 최신'을 검색하되, '정치' 관련 내용은 제외합니다.
    final String query = Uri.encodeComponent('건강+운동+웰빙-정치-날씨');
    final Uri uri = Uri.parse('https://openapi.naver.com/v1/search/news.json?query=$query&display=5&sort=sim');

    try {
      final response = await http.get(
        uri,
        headers: {
          'X-Naver-Client-Id': clientId,
          'X-Naver-Client-Secret': clientSecret,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final SearchResponse searchResponse = SearchResponse.fromJson(jsonResponse);
        return searchResponse.items;
      } else {
        print('Failed to load Naver news: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load Naver news');
      }
    } catch (e) {
      print('Error in _fetchNaverNews: $e');
      rethrow;
    }
  }

  Future<List<SearchResult>> _fetchYoutubeVideos() async {
    _fetchYoutubeVideosCompleted = false;
    const String apiKey = 'AIzaSyBNFUaREtKTnkHmLNz7-tv2L9nv-E_PQxs'; // 실제 사용시에는 안전하게 관리하세요.
    const int maxResults = 5;
    final String query = Uri.encodeComponent('건강 정보 최신 영상');
    final Uri uri = Uri.parse('https://www.googleapis.com/youtube/v3/search?part=snippet&key=$apiKey&q=$query&maxResults=$maxResults&type=video&order=date&regionCode=KR');

    try {
      final response = await http.get(uri);
      _fetchYoutubeVideosCompleted = true;
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final SearchListResponse searchListResponse = SearchListResponse.fromJson(jsonResponse);
        return searchListResponse.items;
      } else {
        print('Failed to load YouTube videos: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load YouTube videos');
      }
    } catch (e) {
      _fetchYoutubeVideosCompleted = true;
      print('Error in _fetchYoutubeVideos: $e');
      rethrow;
    }
  }

  // --- 유틸리티 함수 ---
  Future<void> _launchURL(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $url');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('연결할 수 없습니다: ${url.toString()}')),
          );
        }
      }
    } catch(e) {
      print('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL 실행 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  void _launchYoutubeVideo(String videoId) {
    // 유튜브 앱으로 열기를 시도하고, 실패하면 웹 브라우저로 엽니다.
    // 일반적인 watch URL을 사용하는 것이 다양한 플랫폼에서 안정적입니다.
    final Uri youtubeWatchUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    _launchURL(youtubeWatchUrl); // _launchURL 함수 재사용
  }

}