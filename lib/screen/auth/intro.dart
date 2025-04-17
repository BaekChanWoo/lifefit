import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/screen/auth/register.dart';
import 'package:lifefit/screen/auth/login.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState(){
    super.initState();
    // 초기화
    _animationController = AnimationController(duration: const Duration(seconds: 2)
        , vsync: this);
    // 페이드인 애니매이션(점점 진하게 보임)
    _animation = Tween<double>(begin: 0.0 , end: 1.0).animate(_animationController);
    // 애니매이션 시작
    _animationController.forward();
  }

  @override
  void dispose(){
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 로고
          Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _animation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 로고
                      Image.asset('assets/img/lifefit.png' , width: 280, height: 280,),

                      // 슬로건
                      const SizedBox(height:  20,),
                      const Text(
                        '세상의 하나뿐인 헬스케어',
                        style: TextStyle(fontSize: 24 , fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12,),
                      const Text(
                        '여러분의 건강을 위한 모든 것\n지금 라이프핏을 통해 실현해보세요!',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ),
          // 가입, 로그인 버튼 영역
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 회원 가입
                ElevatedButton(
                    onPressed: (){
                      Get.to(() => const Register());
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity , 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                    child: const Text('시작하기'),
                  ),
                    const SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('이미 계정이 있나요?'),
                        TextButton(
                            onPressed: (){
                              Get.to(() => const Login());
                            },
                          style: TextButton.styleFrom(
                            foregroundColor: PRIMARY_COLOR,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                            child: const Text('로그인'),
                        ),
                      ],
                    )
                // 로그인
              ],
            ),
          ),
        ],
      ),
    );
  }
}
