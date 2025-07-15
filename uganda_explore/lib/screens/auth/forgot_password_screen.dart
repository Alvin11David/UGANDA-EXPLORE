import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uganda_explore/screens/auth/otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String generateOtp() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  Future<bool> sendOtpEmail({
    required String email,
    required String otp,
  }) async {
    const serviceId = 'Uganda_Explore'; // your EmailJS service ID
    const templateId = 'template_b6hthi8'; // your EmailJS OTP template ID
    const userId = 'r1x2A2YyfHtXLLHR0'; // EmailJS public key

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {'email': email, 'otp': otp},
      }),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    return response.statusCode == 200;
  }

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final otp = generateOtp();

    final emailSent = await sendOtpEmail(email: email, otp: otp);

    setState(() {
      _isLoading = false;
    });

    if (emailSent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(email: email, otp: otp),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP email. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], // Navy Blue to Blue
            stops: [0.03, 0.63],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/logo/whiteugandaexplore.png",
                      height: 80,
                      width: 330,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Let's get you\nsorted!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    height: 450,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.5,
                            colors: [
                              Color(0xFF1E3A8A),
                              Color(0xFF3B82F6),
                            ], // Navy Blue to Blue
                            stops: [0.0, 1.0],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.mail,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 130,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Forgot Your Password",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 180,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Please enter your email address below\n to receive an OTP code.",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Wrap the email input and button in a Form
                  Positioned(
                    top: 250,
                    left: 0,
                    right: 0,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Email(controller: emailController),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 320,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signUp,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF1E3A8A),
                                      Color(0xFF3B82F6),
                                    ], // Navy Blue to Blue
                                    stops: [0.0, 0.47],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                        )
                                      : const Text(
                                          'Submit',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Email widget
class Email extends StatelessWidget {
  final TextEditingController controller;
  const Email({super.key, required this.controller});

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: TextFormField(
          controller: controller,
          validator: _validateEmail,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(
              color: Color(0xFF374151), // Dark Gray
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintText: 'Enter Your Email Address',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF), // Light Gray (hint)
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Color(0xFFE5E7EB), // Light Gray background
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.mail, color: Color(0xFF6B7280)), // Gray icon
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 1,
              ), // Blue
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1E3A8A),
                width: 2,
              ), // Navy Blue
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6), // Blue
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1E3A8A),
                width: 2,
              ), // Navy Blue
            ),
            errorStyle: const TextStyle(
              color: Color(
                0xFFEF4444,
              ), // Red for error (can be changed if you want)
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          style: const TextStyle(
            color: Color(0xFF374151), // Dark Gray
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          cursorColor: Color(0xFF3B82F6), // Blue
        ),
      ),
    );
  }
}
