import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HistoryController extends GetxController{
  final box = GetStorage();
  final searchHistory = <String>[].obs;

  @override
  void onInit(){
    super.onInit();
    final raw = box.read<List<dynamic>>('searchHistory') ?? [];
    searchHistory.addAll(raw.cast<String>());
  }

  void addSearchTerm(String term){
    if(searchHistory.contains(term)){
      searchHistory.remove(term);
    }
    searchHistory.insert(0, term);

    if(searchHistory.length > 10){
      searchHistory.removeLast();
    }
    _saveToStorage();
  }

  void removeSearchTerm(String term){
    searchHistory.remove(term);
    _saveToStorage();
  }
  void clearAllSearchTerms(){
    searchHistory.clear();
    _saveToStorage();
  }

  void _saveToStorage(){
    box.write('searchHistory', searchHistory.toList());
  }
}