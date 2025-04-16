import 'package:flutter/material.dart';
import 'package:lifefit/model/meetup_model.dart';
import 'package:lifefit/const/colors.dart';

//게시글 작성

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  // 모집 카테고리 목록
  final List<String> categories = ['러닝', '헬스', '요가', '필라테스', '사이클', '클라이밍', '농구' ];

  //선택한 입력 값들
  String title ='';
  String? selectedCategory;// 종목
  String location = '';//운동 장소
  String description =''; //상세설명
  int selectedMonth = 1; // 날짜 (월)
  int selectedDay = 1;// 날짜 (일)
  int maxPeople = 2; // 최대 모집 인원

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('운동메이트 찾기', textAlign: TextAlign.center), // 다이얼로그 상단 제목
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // 둥근 모서리
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //게시물 제목
              TextField(
                decoration: const InputDecoration(labelText: '제목'),
                onChanged: (val) => location = val,
              ),
              //종목 선택 Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                hint: const Text('종목 선택'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
              ),

              //장소 입력
              TextField(
                decoration: const InputDecoration(labelText: '장소'),
                onChanged: (val) => location = val,
              ),
              const SizedBox(height: 12),

              //상세설명
              TextField(
                decoration: const InputDecoration(labelText: '설명'),
                onChanged: (val) => location = val,
              ),

              const SizedBox(height: 12),
              //날짜 선택 (월, 일)
              Row(
                children: [
                  const Text('날짜'),
                  const SizedBox(width: 16),

                  //월 선택
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: List.generate(12, (i) => i + 1)
                        .map((m) => DropdownMenuItem(value: m, child: Text('$m월')))
                        .toList(),
                    onChanged: (val) => setState(() => selectedMonth = val!),
                  ),

                  const SizedBox(width: 8),

                  // 일 선택
                  DropdownButton<int>(
                    value: selectedDay,
                    items: List.generate(31, (i) => i + 1)
                        .map((d) => DropdownMenuItem(value: d, child: Text('$d일')))
                        .toList(),
                    onChanged: (val) => setState(() => selectedDay = val!),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              //정원 설정
              Row(
                children: [
                  const Text('정원'),
                  const SizedBox(width: 16),

                  //마이너스
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (maxPeople > 1) {
                        setState(() {
                          maxPeople--;
                        });
                      }
                    },
                  ),

                  //현재 정원
                  Text(
                    '$maxPeople',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  //플러스
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (maxPeople < 10) {
                        setState(() {
                          maxPeople++;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // 등록 및 취소 버튼
      actions: [
        // 취소 버튼
        TextButton(
          onPressed: () => Navigator.pop(context), //동작 없이 닫기
          child: const Text('취소', style: TextStyle(color: Colors.black)),
        ),

        // 등록 버튼
        ElevatedButton(
          onPressed: () {
            // 필수 값이 입력되었는지 확인
            if (selectedCategory != null && location.isNotEmpty) {
              // Post 객체 생성
              final newPost = Post(
                title: title,
                description: description,
                category: selectedCategory!,
                location: location,
                dateTime: '2025.$selectedMonth.$selectedDay',
                currentPeople: 1,
                maxPeople: maxPeople,
              );

              Navigator.pop(context, newPost); // 부모로 전달
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
          child: const Text('등록', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
