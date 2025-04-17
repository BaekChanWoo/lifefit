import 'package:flutter/material.dart';

class LabelTextfield extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool isObscure;
  final int maxLines;
  final String? errorText;


  const LabelTextfield({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.isObscure = false,
    this.maxLines = 1, //추가
    this.errorText
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label , style: Theme.of(context).textTheme.labelLarge,),
        const SizedBox(height: 8,),
        TextField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType ?? TextInputType.text,
          maxLines: maxLines, // 추가
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              )
            ),
            focusedBorder:OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16,)
      ],
    );
  }
}
