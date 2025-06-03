import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;

  // TODO: 여기에 실제 발급받은 광고 단위 ID를 입력하세요.
  final String _androidAdUnitId = "ca-app-pub-2097903369246252/1378006710"; // 안드로이드 ID
  final String _iosAdUnitId = "ca-app-pub-2097903369246252/9064925042";     // iOS ID

  String get _adUnitId {
    if (Platform.isAndroid) {
      return _androidAdUnitId;
    } else if (Platform.isIOS) {
      return _iosAdUnitId;
    } else {
      return "unsupported_platform";
    }
  }

  void loadAd() {
    if (_interstitialAd != null || _isAdLoaded || _isShowingAd) {
      print("광고 로드 건너뜀: 광고가 이미 로드되었거나, 로드 중이거나, 표시 중입니다.");
      return;
    }
    print("전면 광고 로드 중...");
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('전면 광고가 성공적으로 로드되었습니다.');
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('전면 광고 로드 실패: $error');
          _interstitialAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showAd({required BuildContext context, required VoidCallback onAdDismissedOrFailed}) {
    if (_isShowingAd) {
      print("광고 표시 건너뜀: 다른 광고가 이미 표시 중입니다.");
      return;
    }
    if (_isAdLoaded && _interstitialAd != null) {
      _isShowingAd = true;
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) => print('전면 광고가 전체 화면으로 표시되었습니다.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('전면 광고가 닫혔습니다.');
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          _isShowingAd = false;
          onAdDismissedOrFailed();
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('전면 광고 전체 화면 표시에 실패했습니다: $error');
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          _isShowingAd = false;
          onAdDismissedOrFailed();
          loadAd();
        },
        onAdClicked: (InterstitialAd ad) => print('전면 광고가 클릭되었습니다.'),
      );
      _interstitialAd!.show();
    } else {
      print('전면 광고가 로드되지 않았습니다. 콜백을 직접 실행합니다.');
      onAdDismissedOrFailed();
      if (!_isAdLoaded) {
        loadAd();
      }
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _isShowingAd = false;
    print("InterstitialAdManager 해제됨.");
  }
}