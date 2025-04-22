// 모집(Post) 모델 정의
class Post {
  final String title; // 제목
  final String description; // 설명
  final String category;  // 운동 카테고리
  final String location; // 운동 장소
  final String dateTime; // 날짜 및 시간
  int currentPeople;// 현재 인원
  int maxPeople;  // 최대 인원

  final bool isMine; // 내가 작성한 글인지 확인
  List<String> applicants;

  Post({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.dateTime,
    required this.currentPeople,
    required this.maxPeople,
    this.isMine=false,
    this.applicants = const [],
  });
}
