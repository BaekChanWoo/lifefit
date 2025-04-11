import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

// 커뮤니티 마이페이지
class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(15.0),
          child: CircleAvatar(
            radius: 50,
              backgroundImage: AssetImage( 'assets/img/mypageimg.jpg',
            ),
          )
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("백찬우",
              style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2.0,),
            Text("헬스랑 러닝을 좋아하며 같이 운동 원해요!!",
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        )
        
      ],
    );
  }
}
