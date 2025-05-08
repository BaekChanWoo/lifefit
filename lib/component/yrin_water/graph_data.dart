import 'package:lifefit/component/yrin_water/individual_bar.dart';


//막대 그래프 사용 요일별 데이터 저장
class BarData {
  final double mon;
  final double tue;
  final double wed;
  final double thu;
  final double fri;
  final double sat;
  final double sun;

  BarData({
    required this.mon,
    required this.tue,
    required this.wed,
    required this.thu,
    required this.fri,
    required this.sat,
    required this.sun,
  });
  //요일별 데이터 IndividualBar 객체 리스트 변환하여 반환.
  List<IndividualBar> get barData => _initializeBarData();

  // 요일별 데이터bIndividualBar 객체 리스트 생성
  List<IndividualBar> _initializeBarData() {
    final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
    return [
      IndividualBar(x: 0, y: mon, label: days[0]),
      IndividualBar(x: 1, y: tue, label: days[1]),
      IndividualBar(x: 2, y: wed, label: days[2]),
      IndividualBar(x: 3, y: thu, label: days[3]),
      IndividualBar(x: 4, y: fri, label: days[4]),
      IndividualBar(x: 5, y: sat, label: days[5]),
      IndividualBar(x: 6, y: sun, label: days[6]),
    ];
  }
}