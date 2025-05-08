import 'package:flutter/material.dart';
import 'package:lifefit/model/youtube_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MusicYoutube extends StatefulWidget {
  final String searchKeyword;

  const MusicYoutube({super.key, required this.searchKeyword});

  @override
    State<MusicYoutube> createState() => _MusicYoutubeState();
}

class _MusicYoutubeState extends State<MusicYoutube> {
  late Future<List<SearchVideoItem>> _searchResultsFuture;

  @override
  void initState() {
    super.initState();
    _searchResultsFuture = fetchYoutubeListWithDio(widget.searchKeyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('"${widget.searchKeyword}" 검색 결과'),
      ),
      body: FutureBuilder<List<SearchVideoItem>>(
        future: _searchResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final searchResults = snapshot.data!;
            return ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final videoItem = searchResults[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => YoutubeVideoPlayerScreen(videoId: videoItem.videoId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row( // Row 위젯을 사용하여 가로로 배치
                      children: [
                        SizedBox(
                          width: 120,
                          height: 90,
                          child: Image.network(
                            videoItem.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error_outline));
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Align( // Align 위젯으로 왼쪽 정렬
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Column 내부 요소 왼쪽 정렬
                              children: [
                                Text(
                                  videoItem.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(videoItem.channelName),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('검색 결과가 없습니다.'));
          }
        },
      ),
    );
  }
}

class YoutubeVideoPlayerScreen extends StatelessWidget {
  final String videoId;

  const YoutubeVideoPlayerScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Player'),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
            ),
          ),
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          onEnded: (data) {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

