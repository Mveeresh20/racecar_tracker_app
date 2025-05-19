import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/on_boarding3.dart';
import 'package:racecar_tracker/Presentation/Pages/sign_in.dart';
import 'package:racecar_tracker/Presentation/Widgets/onboarding_next_button.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/Constants/text.dart';

class OnBoarding2 extends StatefulWidget {
  const OnBoarding2({super.key});

  @override
  State<OnBoarding2> createState() => _OnBoarding2State();
}

class _OnBoarding2State extends State<OnBoarding2> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 1;
  final int _numPages = 3;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  Widget _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(_indicator(i == _currentPage));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: list);
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: isActive ? 10.0 : 8.0,
      width: isActive ? 10.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFCC29) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: isActive ? Border.all(color: Colors.black, width: 1) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              Images.onboarding2,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                 
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2D5586).withOpacity(0.2),
                    Color(0xFF171E45).withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Padding(
                  padding: const EdgeInsets.only(right: 24, top: 20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );
                      },
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          fontFamily: "Nunito Sans",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 340,),

                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Lorempsum.onboarding2Title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: "Nunito Sans",
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        Lorempsum.onboarding2Description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: "Nunito Sans",
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),

               
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 62),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageIndicator(),
                      SizedBox(height: 32),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OnBoarding3()),
                          );
                        },
                        child: OnboardingNextButton(
                          text: "Next",
                          icon: Icons.play_arrow,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
