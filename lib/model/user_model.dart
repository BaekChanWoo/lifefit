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