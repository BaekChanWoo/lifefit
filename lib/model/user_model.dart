// 사용자의 기본 정보를 나타내는 모델
// 피드 페이지에서 게시물 등록자의 프로필 정보
class UserModel{
  late int id;
  late String name;
  int? profile;

  UserModel({required this.id , required this.name});

  UserModel.parse(Map m){
    id = m['id'];
    name = m['name'];
    profile = m['profile_id'];
  }
}