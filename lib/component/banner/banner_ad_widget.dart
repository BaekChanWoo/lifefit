import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late final BannerAd banner;

  @override
  void initState(){
    super.initState();

    // 사용할 광고 ID
    final adUnitId = Platform.isIOS
      ? 'ca-app-pub-2097903369246252/1693092673'
      : 'ca-app-pub-2097903369246252/6608483796';
    
    // 광고를 생성합니다.
    banner = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnitId,
        
        // 광고의 생명주기가 변경될 떄마다 실행할 함수들을 설정
        listener: BannerAdListener(onAdFailedToLoad: (ad , error){
          ad.dispose();
        }), 
        // 광고 요청 정보를 담고 있는 클래스
        request: AdRequest(),
    );
    
        // 광고 로딩
        banner.load();
  }
  
  @override
  void dispose(){
    
    // 위젯이 dispose 되면 광고 또한 dispose
    banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      
      // 광고 높이
      height: 75,
      
      // 광고 위젯에 banner 변수를 입력해줌
      child: AdWidget(ad: banner),
    );
  }
}
