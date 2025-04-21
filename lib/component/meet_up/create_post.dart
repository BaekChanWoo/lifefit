import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/model/meetup_model.dart';
import 'package:lifefit/const/colors.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _formKey = GlobalKey<FormState>();

  final List<String> categories = [
    '러닝', '헬스', '요가', '필라테스', '사이클', '클라이밍', '농구'
  ];

  String title = '';
  String? selectedCategory;
  String location = '';
  String description = '';
  int maxPeople = 2;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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
      title: const Text('운동메이트 찾기', textAlign: TextAlign.center),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: '제목'),
                  onChanged: (val) => title = val,
                  validator: (val) => val == null || val.trim().isEmpty ? '제목을 입력해주세요.' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: const Text('종목 선택'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => setState(() => selectedCategory = value),
                  validator: (val) => val == null ? '종목을 선택해주세요.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: '장소'),
                  onChanged: (val) => location = val,
                  validator: (val) => val == null || val.trim().isEmpty ? '장소를 입력해주세요.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: '설명'),
                  onChanged: (val) => description = val,
                  validator: (val) => val == null || val.trim().isEmpty ? '설명을 입력해주세요.' : null,
                ),
                const SizedBox(height: 20),
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
            if (_formKey.currentState!.validate()) {
              if (selectedDate == null || selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('날짜와 시간을 선택해주세요.')),
                );
                return;
              }
              final dateTimeString =
                  '${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')} '
                  '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
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