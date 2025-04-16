class FeedModel{
  late int id;
  late String title;
  late String content;
  late String name;

  FeedModel.parse(Map m){
    id = m['id'];
    title = m['title'];
    content = m['content'];
    name = m['name'];
  }
}