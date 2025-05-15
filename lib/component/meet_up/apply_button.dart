import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../const/colors.dart';

class ApplyButton extends StatelessWidget {
  final bool isApplied;
  final VoidCallback onPressed;

  const ApplyButton({
    Key? key,
    required this.isApplied,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isApplied ? Colors.grey : PRIMARY_COLOR,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        isApplied ? '신청 완료' : '신청',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
