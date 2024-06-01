import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_app/Screens/Auth/Login/login_screen.dart';

import '../../Components/CustomButton.dart';

class SliderWidget extends StatefulWidget {
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageContent(String imagePath, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 300, fit: BoxFit.contain),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            physics: const BouncingScrollPhysics(),
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildPageContent('assets/splash/slide1.jpg', 'Welcome to UniAlert', 'Experience seamless communication and stay updated with the latest university announcements.'),
              _buildPageContent('assets/splash/slide2.jpg', 'Personalized Notifications', 'Receive tailored notifications based on your interests and campus affiliations, ensuring you never miss important updates.'),
              _buildPageContent('assets/splash/slide3.jpg', 'Stay Connected', 'Stay connected with your university community and stay informed about events, news, and important notices.')
            ],
          ),
          Positioned(
            bottom: 100.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
          Positioned(
            bottom: 20.0,
            child: SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.7,
              child: CustomButton(
                color: Colors.lightGreen,
                onPressed: () {
                  Get.to(SignInScreen());
                },
                text: 'Get Started',
              ),
            ),
          ),
        ],
      ),
    );
  }

}