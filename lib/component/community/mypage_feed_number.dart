import 'package:flutter/material.dart';

class MyPageFeedNumber extends StatelessWidget {
  const MyPageFeedNumber({super.key});

  @override
  Widget build(BuildContext context) {
    int myPostCount = 50;

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0 , top: 8.0,),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("$myPostCount 게시물",
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
            )
          ],
        ),
      ),
    );
  }
}
