import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/model/meetup_model.dart';
import 'package:lifefit/const/colors.dart';

//모집글 작성 및 수정 위젯
class CreatePost extends StatefulWidget {
  final Post? existingPost; // 수정 시 기존 게시글 전달

  const CreatePost({super.key, this.existingPost});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _formKey = GlobalKey<FormState>(); //유효성 검사 키

  final List<String> categories = [
    '러닝', '헬스', '요가', '필라테스', '사이클', '클라이밍', '농구'
  ];

  // 입력값들
  String title = '';
  String? selectedCategory;
  String location = '';
  String description = '';
  int maxPeople = 2;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();

    // 수정 모드일 때 초기값 세팅
    final post = widget.existingPost;
    if (post != null) {
      title = post.title;
      selectedCategory = post.category;
      location = post.location;
      description = post.description;
      maxPeople = post.maxPeople;

      // 날짜/시간 문자열을 DateTime과 TimeOfDay로 분리
      final parts = post.dateTime.split(' ');
      if (parts.length == 2) {
        final date = parts[0].split('.');
        final time = parts[1].split(':');
        selectedDate = DateTime(
          int.parse(date[0]),
          int.parse(date[1]),
          int.parse(date[2]),
        );
        selectedTime = TimeOfDay(
          hour: int.parse(time[0]),
          minute: int.parse(time[1]),
        );
      }
    }
  }

  //날짜 선택 호출
  Future<void> _showCupertinoDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final nowTrimmed = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    DateTime tempPicked = selectedDate ?? nowTrimmed;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              //상단 완료 버튼
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text('완료'),
                    onPressed: () {
                      setState(() {
                        selectedDate = tempPicked;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              // 날짜 선택
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: selectedDate ?? nowTrimmed,
                  minimumDate: nowTrimmed,
                  maximumDate: nowTrimmed.add(const Duration(days: 365)),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime newDate) {
                    tempPicked = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //시간 선택 호출
  Future<void> _showCupertinoTimePicker(BuildContext context) async {
    final now = DateTime.now();
    final nowTrimmed = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    DateTime tempPicked = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime?.hour ?? now.hour,
      selectedTime?.minute ?? now.minute,
    );

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              //상단 완료 버튼
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text('완료'),
                    onPressed: () {
                      setState(() {
                        selectedTime = TimeOfDay.fromDateTime(tempPicked);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              // 시간 선택 본체
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: tempPicked,
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newTime) {
                    tempPicked = newTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // 다이얼로그 제목: 작성과 수정 구분
      title: Text(widget.existingPost == null ? '운동메이트 찾기' : '게시글 수정', textAlign: TextAlign.center),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //제목 입력
                TextFormField(
                  initialValue: title,
                  decoration: const InputDecoration(labelText: '제목'),
                  onChanged: (val) => title = val,
                  validator: (val) => val == null || val.trim().isEmpty ? '제목을 입력해주세요.' : null,
                ),
                const SizedBox(height: 12),

                //종목 선택
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: const Text('종목 선택'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => setState(() => selectedCategory = value),
                  validator: (val) => val == null ? '종목을 선택해주세요.' : null,
                ),
                const SizedBox(height: 12),

                //장소 입력
                TextFormField(
                  initialValue: location,
                  decoration: const InputDecoration(labelText: '장소'),
                  onChanged: (val) => location = val,
                  validator: (val) => val == null || val.trim().isEmpty ? '장소를 입력해주세요.' : null,
                ),
                const SizedBox(height: 12),

                //설명 입력
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(labelText: '설명'),
                  onChanged: (val) => description = val,
                  validator: (val) => val == null || val.trim().isEmpty ? '설명을 입력해주세요.' : null,
                ),
                const SizedBox(height: 20),

                //날짜 및 시간 선택
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCupertinoDatePicker(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
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
                        onTap: () => _showCupertinoTimePicker(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
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

                //정원 선택
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

      //하단 버튼 (취소/등록)
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (selectedDate == null || selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('날짜와 시간을 선택해주세요.')),
                );
                return;
              }

              // 날짜 + 시간 문자열
              final dateTimeString =
                  '${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')} '
                  '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

              // Post 객체 생성 후 반환
              final newPost = Post(
                title: title,
                description: description,
                category: selectedCategory!,
                location: location,
                dateTime: dateTimeString,
                currentPeople: widget.existingPost?.currentPeople ?? 1,
                maxPeople: maxPeople,
                isMine: true,
                applicants: [],
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
