import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lifefit/controller/history_controller.dart';
import 'package:lifefit/component/community/feed_search_result.dart';

class FeedSearchForm extends StatefulWidget {
  const FeedSearchForm({super.key});

  @override
  State<FeedSearchForm> createState() => _FeedSearchFormState();
}

class _FeedSearchFormState extends State<FeedSearchForm> {
  final HistoryController historyController = Get.put(HistoryController());

  void onSubmitted(String keyword){
    historyController.addSearchTerm(keyword);
    Get.off(() => FeedSearchResult(keyword));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: '게시물 검색',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            onSubmitted: onSubmitted,
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 검색',
                  style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: (){
                      historyController.clearAllSearchTerms();
                    },
                    child: const Text('전체 삭제'),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Obx(
                () => Expanded(
                    child: ListView.builder(
                        itemCount: historyController.searchHistory.length,
                        itemBuilder: (context , index){
                          final term = historyController.searchHistory[index];
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(term),
                            onTap: (){
                              onSubmitted(term);
                            },
                            trailing: IconButton(
                                onPressed: (){
                                  historyController.removeSearchTerm(term);
                                },
                                icon: const Icon(Icons.close),
                            ),
                          );
                        })
                )
            )
          ],
        ),
      ),
    );
  }
}
