import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/model/meetup_model.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';


class ApplySheet extends StatefulWidget {
  final Post post;
  final VoidCallback onApplied;

  const ApplySheet({
    Key? key,
    required this.post,
    required this.onApplied,
  }) : super(key: key);

  @override
  State<ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<ApplySheet> {
  late String currentUserId;
  late String currentUserName;
  bool isApplied = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    currentUserId = user?.uid ?? 'guest';

    //이름은 HomeScreenController에서 가져오기
    final homeController = Get.find<HomeScreenController>();
    final rawName = homeController.userName.value;
    currentUserName = rawName.trim().isNotEmpty ? rawName : '익명';

    isApplied = widget.post.applicants.any((app) => app['uid'] == currentUserId);
  }



  Future<void> _handleApply() async {
    final docId = widget.post.docId;
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글 ID가 없습니다.')),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('meetups').doc(docId);

    if (isApplied) {
      // 신청 취소 . uid 일치하는 항목 제거
      widget.post.applicants.removeWhere((applicant) => applicant['uid'] == currentUserId);
      widget.post.currentPeople--;

      await docRef.update({
        'applicants': widget.post.applicants,
        'currentPeople': widget.post.currentPeople,
      });

      setState(() => isApplied = false);
    } else {
      // 신청
      if (widget.post.currentPeople < widget.post.maxPeople) {
        widget.post.applicants.add({
          'uid': currentUserId,
          'name': currentUserName,
        });
        widget.post.currentPeople++;

        await docRef.update({
          'applicants': widget.post.applicants,
          'currentPeople': widget.post.currentPeople,
        });

        setState(() => isApplied = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('정원이 가득 찼습니다.')),
        );
        return;
      }
    }

    widget.onApplied();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [Text(widget.post.location, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 15),
              Text(widget.post.dateTime, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8)
            ],
          ),
          Text(widget.post.description, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            '현재 인원: ${widget.post.currentPeople}명 / ${widget.post.maxPeople}명',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // 신청 / 신청취소 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: isApplied ? Colors.red : PRIMARY_COLOR,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isApplied ? '신청 취소' : '함께 운동하기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
