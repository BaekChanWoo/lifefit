import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifefit/const/colors.dart';

class CustomTextField extends StatelessWidget {
  //const CustomTextField({super.key});
  final String label; // 텍스트 필드 제목
  final bool isTime; // 시간 선택하는 텍스트 필드 여부
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;

  const CustomTextField({
    required this.label,
    required this.isTime,
    required this.onSaved,
    required this.validator,
    Key? key,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, style: TextStyle(
          color: PRIMARY_COLOR,
          fontWeight: FontWeight.w600,
        ),
        ),
        Expanded(
            flex: isTime ? 0 : 1,
            child: TextFormField(
              onSaved: onSaved,
              validator: validator,
              cursorColor: Colors.grey, // 커서 색생 변경
              maxLines: isTime ? 1 : null, // 입력 최대 줄 개수
              expands: !isTime, // 시간 관련 텍스트 필드 공간 최대 차지
              keyboardType: isTime? TextInputType.number : TextInputType.multiline,
              // 시간 관련 텍스트 필드 = 기본 숫자 키보드
              // 내욘 텍스트 필드 - 일반 키보드
              inputFormatters: isTime ? [ // 텍스트 필드 입력 값 제한
                FilteringTextInputFormatter.digitsOnly,
              ]
                : [], // 시간 필드는 숫자만 입력하도록 제한
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[250],
                suffixText: isTime ? '시' : null, // '시' 접미사 추가
              ),
            ),
        ),
      ],
    );
  }
}
