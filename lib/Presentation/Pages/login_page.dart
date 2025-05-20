import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG assets
import 'package:google_fonts/google_fonts.dart';
import 'package:racecar_tracker/Presentation/Pages/home_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/sign_up.dart';
import 'package:racecar_tracker/Presentation/Widgets/onboarding_next_button.dart';
import 'package:racecar_tracker/Presentation/Widgets/or_divider.dart';
import 'package:racecar_tracker/Presentation/Widgets/sign_in_button.dart';
import 'package:racecar_tracker/Services/auth_service.dart';
import 'package:racecar_tracker/Utils/Constants/ui.dart'; //for google fonts

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  void _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        print("User signed in: ${user.email}");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size(screenWidth, screenHeight),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: screenHeight * 0.12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in',
                      style: GoogleFonts.montserrat(
                        // Use Google Fonts
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12), 
                   
                    Text(
                      'Login to access your account',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
            
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            offset: Offset(0, 12),
                            color: Color(0xFF989898).withAlpha(140),
                          ),
                        ],
                        borderRadius: UI.borderRadius24,
            
                        color: Color(0xFF13386B),
                        border: Border.all(
                          color: Colors.white.withAlpha(100),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "Email",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Plus Jakarta Sans",
                                ),
                              ),
                            ),
                            SizedBox(height: 8), 
                           
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
            
                                fillColor: Color(0xFF3B537D),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                labelText: 'Enter your email..',
                                labelStyle: const TextStyle(color: Colors.white),
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                ),
            
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
            
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "Password",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Plus Jakarta Sans",
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            // Password Text Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible, // Toggle visibility
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFF3B537D),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                labelText: 'Enter your password..',
                                labelStyle: const TextStyle(color: Colors.white),
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                ),
            
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
            
                            InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  // Perform login action
                                  print(
                                    'Email: ${_emailController.text}, Password: ${_passwordController.text}',
                                  );
                                  _handleSignIn();
                                }
                              },
            
                              child: OnboardingNextButton(
                                text: "SIGN IN",
                                icon: Icons.play_arrow,
                              ),
                            ),
                            SizedBox(height: 20),
                            OrDivider(), // 4% spacing
            
                            SizedBox(height: 20), // 3% spacing
                            // or Si Icon(icon, size: 16, color: Colors.black),sign in with
                            InkWell(
                              onTap: () {
                                _authService.signInWithApple();
                              },
                              child: SignInButton(
                                text: "Sign in with Apple",
                                icon: Icons.apple,
                                iconFirst: true,
                              ),
                            ),
                            SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                _authService.signInAnonymously(context);
                              },
                              child: SignInButton(
                                text: "Continue as Guest",
                                icon: Icons.play_arrow,
                                iconFirst: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 90),
            
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Montserrat",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Montserrat",
                              color: Color(0xFF2D5586), // Make "Sign up" blue
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the background
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // First color (Top part - Blue)
    paint.color = const Color(0xFF2D5586); // Darker blue
    final path = Path();
    path.lineTo(0, size.height * 0.8); // Adjusted split point
    path.quadraticBezierTo(
      size.width / 2,
      size.height * 0.5,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, paint);

    // Second color (Bottom part - Yellow)
    paint.color = const Color(0xFFFFCC29); // Yellow
    final path2 = Path();
    path2.moveTo(0, size.height * 0.48); // Adjusted split point
    path2.quadraticBezierTo(
      size.width / 2,
      size.height * 0.38,
      size.width,
      size.height * 0.3,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
