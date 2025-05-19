import 'package:flutter/material.dart';
import 'package:lifefit/model/youtube_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeSearch extends StatefulWidget {
  final String searchKeyword;

  const YoutubeSearch({super.key, required this.searchKeyword});

  @override
  State<YoutubeSearch> createState() => _YoutubeSearchState();
}

class _YoutubeSearchState extends State<YoutubeSearch> {
  late Future<List<SearchVideoItem>> _searchResultsFuture;

  @override
  void initState() {
    super.initState();
    _searchResultsFuture = fetchYoutubeListWithDio(widget.searchKeyword);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SearchVideoItem>>(
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
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          YoutubeVideoPlayerScreen(videoId: videoItem.videoId),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
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
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}

class YoutubeVideoPlayerScreen extends StatelessWidget {
  final String videoId;

  const YoutubeVideoPlayerScreen({super.key, required this.videoId});

  //수정 중

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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