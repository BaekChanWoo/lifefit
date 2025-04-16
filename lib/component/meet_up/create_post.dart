import 'package:flutter/material.dart';
import 'package:lifefit/model/meetup_model.dart';
import 'package:lifefit/const/colors.dart';

//모집글 작성 화면

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  // 폼 전체를 제어할 수 있는 key
  final _formKey = GlobalKey<FormState>();

  // 카테고리 목록
  final List<String> categories = ['러닝', '헬스', '요가', '필라테스', '사이클', '클라이밍', '농구'];

  // 입력값
  String title = '';
  String? selectedCategory;
  String location = '';
  String description = '';
  int maxPeople = 2;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('운동메이트 찾기', textAlign: TextAlign.center),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      content: Form( // 폼 위젯으로 감싸기
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //제목 입력
                TextFormField(
                  decoration: const InputDecoration(labelText: '제목'),
                  onChanged: (val) => title = val,
                  validator: (val) =>
                  val == null || val.trim().isEmpty ? '제목을 입력해주세요.' : null,
                ),

                const SizedBox(height: 12),

                //종목 선택
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: const Text('종목 선택'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCategory = value),
                  validator: (val) => val == null ? '종목을 선택해주세요.' : null,
                ),

                const SizedBox(height: 12),

                // 장소 입력
                TextFormField(
                  decoration: const InputDecoration(labelText: '장소'),
                  onChanged: (val) => location = val,
                  validator: (val) =>
                  val == null || val.trim().isEmpty ? '장소를 입력해주세요.' : null,
                ),

                const SizedBox(height: 12),

                //설명 입력
                TextFormField(
                  decoration: const InputDecoration(labelText: '설명'),
                  onChanged: (val) => description = val,
                  validator: (val) =>
                  val == null || val.trim().isEmpty ? '설명을 입력해주세요.' : null,
                ),

                const SizedBox(height: 20),

                // 날짜 , 시간 선택
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? now,
                            firstDate: now,
                            lastDate: DateTime(now.year + 1),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedDate != null
                                ? '${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')}'
                                : '날짜 선택',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => selectedTime = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedTime != null
                                ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                : '시간 선택',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                //정원
                Row(
                  children: [
                    const Text('정원'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (maxPeople > 1) {
                          setState(() => maxPeople--);
                        }
                      },
                    ),
                    Text('$maxPeople', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (maxPeople < 10) {
                          setState(() => maxPeople++);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: Colors.black)),
        ),

        ElevatedButton(
          onPressed: () {
            // 폼 유효성 검사 먼저 수행
            if (_formKey.currentState!.validate()) {
              if (selectedDate == null || selectedTime == null) {
                // 날짜/시간 선택 안 했을 때는 별도로 처리
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('날짜와 시간을 선택해주세요.')),
                );
                return;
              }

              // 날짜, 시간 문자열 조합
              final dateTimeString =
                  '${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')} '
                  '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

              // Post 객체 생성 및 등록
              final newPost = Post(
                title: title,
                description: description,
                category: selectedCategory!,
                location: location,
                dateTime: dateTimeString,
                currentPeople: 1,
                maxPeople: maxPeople,
              );

              Navigator.pop(context, newPost);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
          child: const Text('등록', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
