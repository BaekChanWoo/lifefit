class ScheduleModel {
  final String id;
  final String content;
  final DateTime date;
  final int startTime;
  final int endTime;

  ScheduleModel({
    required this.id,
    required this.content,
    required this.date,
    required this.startTime,
    required this.endTime,
});

  // JSON으로부터 모델을 만들어내는 생성자( JSON -> 다트 객체 )
  ScheduleModel.fromJson({
    required Map<String , dynamic> json,
}) : id = json['id'],
     content = json['content'],
     date = DateTime.parse(json['date']),
     startTime = json['startTime'],
     endTime = json['endTime'];

  // 모델을 다시 JSON으로 변환 ( 다트 객체 -> JSON )
  Map<String ,  dynamic> toJson(){
    return {
      'id' : id,
      'content' : content,
      'date' :
      '${date.year}${date.month.toString().padLeft(2,'0')}${date.day.toString().padLeft(2,'0')}',
      'startTime' : startTime,
      'endTime' : endTime,
    };
  }

  // 현재 모델을 특정 속성만 변환해서 새로 생성
  // 존재하는 인스턴스에서 몇 개의 값만 변경
  ScheduleModel copyWith({
    String? id,
    String? content,
    DateTime? date,
    int? startTime,
    int? endTime,
}) {
    return ScheduleModel(
        id: id ?? this.id,
        content: content ?? this.content,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime
    );
  }
}