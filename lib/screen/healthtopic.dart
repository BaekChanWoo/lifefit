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
  Timer? _sliderTimer; // 슬라이더 자동 넘김 타이머 객체
  bool _isUserInteracting = false; // 사용자가 슬라이더와 상호작용 중인지 여부

  // 실시간 토픽 데이터를 위한 Future 상태 변수
  Future<List<ArticleItem>>? _naverNewsFuture;

  // HTML 엔티티 변환기 인스턴스 (클래스 멤버로 한 번만 생성)
  final HtmlUnescape _unescape = HtmlUnescape();

  bool _isLoadingNewsSlider = true;
  bool _isLoadingYoutubeVideos = true;


  @override
  void initState() {
    super.initState();
    _startSliderTimer(); // 타이머 시작 함수 호출

    _fetchNewsSliderData(); // 카드 슬라이더 뉴스 데이터 가져오기
    _naverNewsFuture = _fetchNaverNews(); // 실시간 토픽 데이터 Future 초기화
    _fetchYoutubeVideos().then((videos) {
      if (mounted) {
        setState(() {
          _youtubeVideos = videos;
          _isLoadingYoutubeVideos = false; // 유튜브 영상 로딩 완료
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isLoadingYoutubeVideos = false; // 유튜브 영상 로딩 실패 시에도 완료 처리
        });
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel(); // 위젯 dispose 시 타이머 취소
    controller.dispose();
    super.dispose();
  }

  // 슬라이더를 다음 페이지로 넘기는 로직
  void _goToNextPage() {
    if (controller.hasClients && controller.page != null && _newsSliderArticles.isNotEmpty) {
      final int itemCount = _newsSliderArticles.length > 4 ? 4 : _newsSliderArticles.length;
      if (itemCount == 0) return;
      final int currentPage = controller.page!.round(); // 현재 페이지 반올림
      final int nextPage = (currentPage + 1) % itemCount;
      controller.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    }
  }

  // 슬라이더 자동 넘김 타이머 시작 함수
  void _startSliderTimer() {
    _sliderTimer?.cancel(); // 기존 타이머가 있다면 취소
    _sliderTimer = Timer.periodic(Duration(seconds: 7), (Timer timer) {
      if (!_isUserInteracting && mounted) { // 사용자가 상호작용 중이 아니고, 위젯이 마운트된 상태일 때만 실행
        _goToNextPage();
      }
    });
  }

  // 슬라이더 자동 넘김 타이머 중지 함수
  void _stopSliderTimer() {
    _sliderTimer?.cancel();
  }


  // HTML 엔티티 변환 및 태그 제거를 위한 함수
  String cleanHtmlString(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) return '';
    var textWithoutEntities = _unescape.convert(htmlText);
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return textWithoutEntities.replaceAll(exp, '');
  }

  // 카드 슬라이더 뉴스 데이터 가져오기 (Newsdata.io)
  Future<void> _fetchNewsSliderData() async {
    if(mounted) { // setState 호출 전 mounted 확인
      setState(() {
        _isLoadingNewsSlider = true;
      });
    }
    try {
      final newsDataIo = await _fetchNewsDataIoApi();
      if (mounted) {
        setState(() {
          _newsSliderArticles.clear();
          _newsSliderArticles.addAll(newsDataIo);
          _newsSliderArticles.sort((a, b) {
            DateTime? dateA = DateTime.tryParse(a.pubDate);
            DateTime? dateB = DateTime.tryParse(b.pubDate);
            DateTime fallbackDate = DateTime.fromMillisecondsSinceEpoch(0);
            return (dateB ?? fallbackDate).compareTo(dateA ?? fallbackDate);
          });
          _isLoadingNewsSlider = false; // 뉴스 슬라이더 로딩 완료
        });
      }
    } catch (e) {
      print('Error fetching news slider data: $e');
      if (mounted) {
        setState(() {
          _isLoadingNewsSlider = false; // 뉴스 슬라이더 로딩 실패 시에도 완료 처리
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('슬라이더 뉴스를 불러오는데 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) {
        // _fetchNewsSliderDataCompleted = true; // 이 플래그는 _isLoadingNewsSlider로 대체 가능
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
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('잘못된 URL 형식입니다.')));
                }
              } else {
                print('Empty or null URL for realTimeTopic');
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('URL 정보가 없습니다.')));
              }
            },
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // 배경색은 Card와 동일하게 또는 다르게 설정 가능
                    borderRadius: BorderRadius.circular(10.0), // 필요시 디자인 조정
                  ),
                  width: 70.0,
                  height: 70.0,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor), // 테마 색상 사용 등
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
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
          elevation: 0.0, // 카드 자체 그림자 제거 (디자인에 따라)
          color: Colors.white,
          child: InkWell(
            onTap: () {
              if (videoId != null && videoId.isNotEmpty) {
                _launchYoutubeVideo(videoId);
              } else {
                print('Video ID is null or empty');
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('영상을 재생할 수 없습니다.')));
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)), // 카드 상단 모서리에만 적용
                      child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                          ? Image.network(
                        thumbnailUrl,
                        width: 290.0, // 카드 너비에 맞게 조정 가능
                        height: 164.0,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container( // 로딩 중 플레이스홀더 크기 명시
                            width: 290.0,
                            height: 164.0,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
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
                    width: 274.0, // 썸네일 너비에 맞게 조정
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title.isNotEmpty ? title : '제목 없음',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), // 폰트 크기 등 조정
                            overflow: TextOverflow.ellipsis, maxLines: 2),
                        SizedBox(height: 4.0), // 간격 조정
                        Text(channelTitle.isNotEmpty ? channelTitle : '채널 정보 없음',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]), // 스타일 조정
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
    final int sliderItemCount = _newsSliderArticles.isEmpty ? 0 : (_newsSliderArticles.length > 4 ? 4 : _newsSliderArticles.length);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '건강토픽',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 최상단 이미지 슬라이드 뉴스
            if (_isLoadingNewsSlider)
              Container(
                height: 320,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (sliderItemCount > 0)
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 320,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        if (notification is ScrollStartNotification) {
                          if (notification.dragDetails != null) {
                            if (mounted) {
                              setState(() {
                                _isUserInteracting = true;
                              });
                            }
                            _stopSliderTimer();
                          }
                        } else if (notification is ScrollEndNotification) {
                          Future.delayed(Duration(seconds: 3), () { // 사용자가 손을 뗀 후 3초 뒤 타이머 재시작
                            if (mounted && _isUserInteracting) { // 사용자가 실제로 인터랙션 했을때만 상태 변경 및 타이머 재시작
                              setState(() {
                                _isUserInteracting = false;
                              });
                              _startSliderTimer();
                            } else if (mounted && !_isUserInteracting) { // 스크롤만 하고 인터랙션 상태가 아니었다면 (프로그래밍적 스크롤 등) 바로 타이머 시작
                              _startSliderTimer();
                            }
                          });
                        }
                        return false;
                      },
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
                          final title = cleanHtmlString(article.title);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: InkWell(
                              onTap: () async {
                                // _stopSliderTimer(); // 탭 시 타이머 중지 (선택적)
                                // if(mounted) setState(() => _isUserInteracting = true);

                                if (article.link.isNotEmpty) {
                                  final Uri? url = Uri.tryParse(article.link);
                                  if (url != null) {
                                    await _launchURL(url); // await 추가
                                  } else {
                                    print('Invalid URL format for news slider: ${article.link}');
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('잘못된 URL 형식입니다.')));
                                  }
                                } else {
                                  print('Empty URL for news slider article');
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('URL 정보가 없습니다.')));
                                }
                                // 외부 앱에서 돌아왔을 때 타이머를 자동으로 재시작하려면 AppLifecycleState를 관찰해야 함.
                                // 여기서는 사용자가 다시 화면과 상호작용할 때 NotificationListener에 의해 타이머가 재시작될 수 있음.
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                elevation: 4.0,
                                clipBehavior: Clip.antiAlias,
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
                  ),
                  if (sliderItemCount > 1)
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
            else
              Container(
                height: 320,
                child: Center(child: Text('뉴스가 없습니다.')),
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
                    // itemCount만큼의 높이 확보 5개로 제한
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(), // 부모가 SingleChildScrollView이므로 스크롤 비활성화
                      itemCount: naverArticles.length > 5 ? 5 : naverArticles.length,
                      itemBuilder: (context, index) {
                        final article = naverArticles[index];
                        return _buildContentCard(
                          {
                            'title': article.title,
                            'link': article.link,
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
              child: _isLoadingYoutubeVideos
                  ? Center(child: CircularProgressIndicator())
                  : _youtubeVideos.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _youtubeVideos.length > 5 ? 5 : _youtubeVideos.length, // 최대 5개 영상 표시
                itemBuilder: (context, index) {
                  final video = _youtubeVideos[index];
                  return Padding(
                    padding: EdgeInsets.only(right: index == (_youtubeVideos.length > 5 ? 4 : _youtubeVideos.length -1) ? 0 : 10.0), // 마지막 아이템 오른쪽 패딩 제거
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
                  : Center(child: Text('현재 영상이 없습니다.')),
            ),
            SizedBox(height: 48.0),
          ],
        ),
      ),
    );
  }

  // --- API 호출 함수들 ---
  Future<List<NewsArticle>> _fetchNewsDataIoApi() async {
    const String apiKey = 'pub_8514684c9e5ae1f3e898c8550491c72eebe05';
    final String query = Uri.encodeComponent('(건강 OR 웰빙) NOT (정치 or 날씨)');
    final Uri uri = Uri.parse('https://newsdata.io/api/1/news?country=kr&q=$query&language=ko&apikey=$apiKey');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> results = decodedJson['results'] as List<dynamic>? ?? [];
        return results.map((jsonItem) => NewsArticle.fromJson(jsonItem as Map<String, dynamic>)).toList();
      } else {
        print('Failed to load news from newsdata.io: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load news from newsdata.io');
      }
    } catch (e) {
      print('Error in _fetchNewsDataIoApi: $e');
      rethrow;
    }
  }

  Future<List<ArticleItem>> _fetchNaverNews() async {
    const String clientId = 'E8ElLohbjuT1eaH79agX';
    const String clientSecret = 'PAqjeoE83U';
    final String query = Uri.encodeComponent('건강+운동+웰빙');
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
    if (mounted) { // setState 호출 전 mounted 확인
      setState(() {
        _isLoadingYoutubeVideos = true;
      });
    }
    const String apiKey = 'AIzaSyBNFUaREtKTnkHmLNz7-tv2L9nv-E_PQxs';
    const int maxResults = 5;
    final String query = Uri.encodeComponent('건강 정보 최신 영상');
    final Uri uri = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?'
            'part=snippet&key=$apiKey&q=$query&maxResults=$maxResults&'
            'type=video&order=date&regionCode=KR&videoDuration=medium');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final SearchListResponse searchListResponse = SearchListResponse.fromJson(jsonResponse);
        return searchListResponse.items;
      } else {
        print('Failed to load YouTube videos: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load YouTube videos');
      }
    } catch (e) {
      print('Error in _fetchYoutubeVideos: $e');
      rethrow;
    }
  }

  // --- 수정된 유틸리티 함수 ---
  Future<bool> _launchURL(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true; // 성공 시 true 반환
      } else {
        print('Could not launch $url');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('연결할 수 없습니다')),
          );
        }
        return false; // 실패 시 false 반환
      }
    } catch(e) {
      print('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL 실행 중 오류가 발생했습니다.')),
        );
      }
      return false; // 예외 발생 시 false 반환
    }
  }

  void _launchYoutubeVideo(String videoId) async { // async 키워드 추가
    final Uri youtubeAppUrl = Uri.parse('youtube://watch?v=$videoId');
    final Uri youtubeWebUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');

  // 1. 앱으로 실행 시도하고 결과를 기다림
  final bool launchedInApp = await _launchURL(youtubeAppUrl);

  // 2. 앱 실행이 실패했다면(!launchedInApp), 웹으로 실행
  if (!launchedInApp) {
  print('Could not launch YouTube app, trying web URL...');
  await _launchURL(youtubeWebUrl);
    }
  }
}