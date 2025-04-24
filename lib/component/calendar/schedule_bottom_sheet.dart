import 'package:flutter/material.dart';
import 'package:lifefit/component/calendar/custom_text_field.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/model/schedule_model.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate; // 선택된 날짜 상위 위젯에서 입력받기
  const ScheduleBottomSheet({super.key , required this.selectedDate});

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime; // 시작 시간 저장 변수
  int? endTime; // 종료 시간 저장 변수
  String? content; // 일정 내용 저장 변수

  @override
  Widget build(BuildContext context) {
    // 키보드 높이
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: formKey,
      child: SafeArea(
          child: Container(
            // 화면 반 높이에 키보드 높이 추가
            height: MediaQuery.of(context).size.height / 2 + bottomInset,
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.only(left: 8 , right: 8, top: 8, bottom: bottomInset),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: CustomTextField( // 시작 시간 입력 필드
                          label: '시작 시간',
                          isTime: true,
                        onSaved: (String? val){
                            startTime = int.parse(val!);
                        },
                        validator: timeValidator,
                      ),
                      ),
                      const SizedBox(width: 16.0,),
                      Expanded(child: CustomTextField( // 종료 시간 입력 필드
                          label: '종료 시간',
                          isTime: true,
                          onSaved: (String? val) {
                            endTime = int.parse(val!);
                          },
                        validator: timeValidator,
                      ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0,),
                  Expanded(
                          child: CustomTextField( // 내용 입력 필드
                              label: '내용',
                              isTime: false,
                            onSaved: (String? val){
                                content = val;
                            },
                            validator: contentValidator,
                          ),
                      ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton( // 저장 버튼
                      onPressed: () => onSavePressed(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //foregroundColor: PRIMARY_COLOR,
                        backgroundColor: PRIMARY_COLOR,
                      ),
                      child: Text('저장'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }

  void onSavePressed(BuildContext context) async{
    if(formKey.currentState!.validate()){
      formKey.currentState!.save(); // 폼 저장

      // 스케쥴 모델 생성하기
      final schedule = ScheduleModel(
          id: Uuid().v4() , // Uuid() 고유한 ID를 생성(중복 X ) , FireSotre 문서 ID를 직접 생성할 때
          content: content!,
          date: widget.selectedDate,
          startTime: startTime!,
          endTime: endTime!,
      );

      // 스케쥴 모델 파이어스토어에 삽입하기
      await FirebaseFirestore.instance
            .collection(
            'schedule', // 가져오고 싶은 컬렉션 이름
      )
      .doc(schedule.id) // 저장하고 싶은 문서의 ID
      .set(schedule.toJson()); // 저장하고 싶은 데이터

      Navigator.of(context).pop();
    }
  }
  String? timeValidator(String? val){ // 시간 필드 검증 함수
    if(val == null){
      return "값을 입력해주세요";
    }
    int? number;

    try{
      number = int.parse(val);
    } catch (e) {
      return "숫자를 입력해주세요";
    }
    if(number < 0 || number > 24){
      return "0시부터 24시 사이를 입력해주세요";
    }
    return null;
  }
  String? contentValidator(String? val){ // 내용 필드 검증 함수
    if(val == null || val.isEmpty){ // val.length == 0
      return "내용을 입력해주세요";
    }
    return null;
  }
}

