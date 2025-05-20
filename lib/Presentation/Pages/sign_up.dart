import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:racecar_tracker/Presentation/Pages/home_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/login_page.dart';
import 'package:racecar_tracker/Presentation/Widgets/onboarding_next_button.dart';
import 'package:racecar_tracker/Presentation/Widgets/or_divider.dart';
import 'package:racecar_tracker/Presentation/Widgets/sign_in_button.dart';
import 'package:racecar_tracker/Services/auth_service.dart';
import 'package:racecar_tracker/Utils/Constants/ui.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _authService = AuthService();

  void _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      print("Form is valid");

      final user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        print("User signed up: ${user.email}");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sign-up failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  bool _passwordVisible = false;
  String? _validateEmail(String? value) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (value == null || value.isEmpty) return "Email is required";
    if (!regex.hasMatch(value)) return "Enter a valid email address";
    return null;
  }

  String? _validatePassword(String? value) {
    const pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    final regex = RegExp(pattern);
    if (value == null || value.isEmpty) return "Password is required";
    if (!regex.hasMatch(value)) {
      return "Password must include uppercase, lowercase, number, and special character";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return "Passwords do not match";
    return null;
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
                      'Sign up',
                      style: GoogleFonts.montserrat(
                        // Use Google Fonts
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12), // 1% spacing
                    // Login to access your account subtitle
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
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
                            SizedBox(height: 8), // 6% spacing
                            // Email Text Field
                            TextFormField(
                              controller: _emailController,
                              validator: _validateEmail,
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
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
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
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
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
                              validator: _validatePassword,
                              obscureText:
                                  !_passwordVisible, // Toggle visibility
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFF3B537D),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                labelText: 'Enter your password..',
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
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
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                "Confirm Password",
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
                              validator: _validateConfirmPassword,
                              controller: _confirmpasswordController,
                              obscureText:
                                  !_passwordVisible, // Toggle visibility
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFF3B537D),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                labelText: 'Enter your password..',
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                hintText: 'Confiem Password',
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
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  _handleSignUp();
                                }
                              },

                              child: OnboardingNextButton(
                                text: "SIGN UP",
                                icon: Icons.play_arrow,
                              ),
                            ),
                            SizedBox(height: 20),
                            OrDivider(),

                            SizedBox(height: 20),

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
                    SizedBox(height: 17),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
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
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign in',
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
