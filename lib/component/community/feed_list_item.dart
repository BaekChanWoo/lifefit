import 'package:flutter/material.dart';

// 이미지 크기
const double _imageSize = 100;

// 피드(게시물) 리스트 아이템 목록
class FeedListItem extends StatelessWidget {
  const FeedListItem({super.key});


  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset('assets/img/mypageimg.jpg',
                    width: _imageSize,
                    height: _imageSize,
                    fit: BoxFit.cover,
                ),
                /*
                Image.network( // 서버에 저장된 URL을 바탕으로 보여줌
                  "https://example.com/image.jpg",
                  width: _imageSize,
                  height: _imageSize,
                  fit: BoxFit.cover,
                ),*/
              ),
              // 정보
              Flexible(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("요가는 이렇게!!",
                          overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16),
                          ),
                          Row(
                            children: [
                              Text('서울 노원구',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(' 3분전',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          /*
                          Text('백찬우',
                            style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),
                          ),*/
                        ],
                      ),
                  ),
              ),
              IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.more_vert,
                  color: Colors.grey,
                    size: 16,
                  ),
              ),
              // 기타
            ],
          ),
            Positioned(
                left: 111,
                bottom: 0,
                child: Text('백찬우',
                  style: TextStyle(
                      fontSize: 16 , fontWeight: FontWeight.bold),
                ),
            ),
            Positioned(
              right: 10,
              bottom: 0,
                child: Row(
                  children: [
                    Icon(
                      Icons.message_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),
                    SizedBox(width: 2,),
                    Text(
                      '1',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(width: 4,),
                    Icon(
                      Icons.favorite_border,
                      color: Colors.grey,
                      size: 16,
                    ),
                    SizedBox(width: 2,),
                    Text(
                      '1',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
            ),
        ],
        ),
      ),
    );
  }
}
