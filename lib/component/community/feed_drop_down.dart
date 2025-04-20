import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class FeedDropDown extends StatefulWidget {
  const FeedDropDown({super.key});

  @override
  State<FeedDropDown> createState() => _FeedDropDownState();
}

class _FeedDropDownState extends State<FeedDropDown> {
  String selectedValue = '요가';
  final List<String> items = ['요가' , '헬스' , '클라이밍' , '러닝' , '싸이클' , '필라테스' , '농구'];


  @override
  Widget build(BuildContext context) {
    return DropdownButton2(
        hint: Text('운동 종목'),
        items: items.map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15),
            ),
        )).toList(),
        value: selectedValue,
        onChanged: (String? value){
          setState(() {
            if(value != null) {
              selectedValue = value;
            }
          });
        },
      buttonStyleData: ButtonStyleData(
        padding: const EdgeInsets.only(left: 8, right: 2),
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey, // 테두리 색상
            width: 1.0, // 테두리 두께
          ),
          borderRadius: BorderRadius.circular(10), // 테두리 모서리 반경
          color: Colors.white, // 배경색 (선택 사항)
        ),
      ),
    );
  }
}
