import 'package:flutter/material.dart';
import 'package:lifefit/model/meetup_model.dart';

//신청자 명단 바텀시트
class ApplicantList extends StatelessWidget {
  final Post post; //해당 모집글 정보

  const ApplicantList({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    //실제 신청자 리스트 사용 (없을 경우 기본 메시지)
    final List<String> applicants = post.applicants;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      maxChildSize: 0.75,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: applicants.isEmpty
              ? const Center(child: Text('아직 신청한 사람이 없습니다.'))
              : ListView(
            controller: scrollController,
            children: [
              const Text(
                '신청자 명단',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...applicants.map((name) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(name),
              )),
            ],
          ),
        );
      },
    );
  }
}
