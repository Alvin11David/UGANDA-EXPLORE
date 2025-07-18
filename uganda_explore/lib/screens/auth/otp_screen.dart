import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:uganda_explore/screens/auth/change_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String otp;

  const OtpScreen({super.key, required this.email, required this.otp});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  String? _errorText;
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() async {
    setState(() {
      _isLoading = true; // 2. Start loading
    });
    final enteredOtp = _otpControllers.map((c) => c.text).join();
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Optional: simulate delay
    if (enteredOtp == widget.otp) {
      setState(() {
        _isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(email: widget.email),
        ),
      );
    } else {
      setState(() {
        _isLoading = false; // 2. Stop loading on error
        _errorText = "Invalid code. Please try again.";
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _errorText = null;
    });

    final newOtp =
        (1000 +
                (9999 *
                    (DateTime.now().millisecondsSinceEpoch % 10000) /
                    10000))
            .floor()
            .toString();

    // Optionally show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': 'Uganda_Explore',
          'template_id': 'template_b6hthi8',
          'user_id': 'r1x2A2YyfHtXLLHR0', // This is the public key from EmailJS
          'template_params': {'email': widget.email, 'otp': newOtp},
        }),
      );

      Navigator.of(context).pop(); // Remove the loading indicator

      if (response.statusCode == 200) {
        setState(() {
          _errorText = null;
          // Replace old OTP with new OTP
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(email: widget.email, otp: newOtp),
            ),
          );
        });
      } else {
        setState(() {
          _errorText = 'Failed to send OTP. Try again.';
        });
      }
    } catch (e) {
      Navigator.of(context).pop(); // Remove loading
      setState(() {
        _errorText = 'An error occurred. Please try again.';
      });
    }
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 48,
          height: 60,
          margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151), // Dark Gray
            ),
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Color(0xFFE5E7EB), // Light Gray background
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF3B82F6), // Blue
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF3B82F6), // Blue
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1E3A8A), // Navy Blue
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
              }
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
              }
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], // Navy Blue to Blue
            stops: [0.03, 0.63],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/logo/whiteugandaexplore.png',
                  width: 268,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Let’s get you \nsorted!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A), // Navy Blue
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 0),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Transform.translate(
                          offset: const Offset(0, 10),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.0,
                                colors: [
                                  Color(0xFF1E3A8A), // Navy Blue
                                  Color(0xFF3B82F6), // Blue
                                ],
                                stops: [0.03, 0.63],
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF1E3A8A), // Navy Blue
                                  size: 50,
                                ),
                                Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF3B82F6), // Blue
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          "Verify Your Email",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A), // Navy Blue
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 0,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151), // Dark Gray
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text: "Please enter the 4-digit code sent to ",
                              ),
                              TextSpan(
                                text: widget.email,
                                style: const TextStyle(
                                  color: Color(0xFF3B82F6), // Blue
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildOtpFields(),
                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorText!,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                          ), // Red for error
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF3B82F6), // Blue
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: _resendOtp,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF3B82F6), // Blue
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Resend",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Color(0xFF3B82F6), // Blue
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GestureDetector(
                          onTap: _isLoading ? null : _verifyOtp,
                          child: SizedBox(
                            width: 323,
                            height: 56,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1E3A8A), // Navy Blue
                                    Color(0xFF3B82F6), // Blue
                                  ],
                                  stops: [0.0, 0.47],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF1E3A8A), // Navy Blue
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                        "Verify Now",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/signin');
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            children: [
                              const TextSpan(
                                text: "Back to ",
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                ), // Dark Gray
                              ),
                              const TextSpan(
                                text: "Sign In",
                                style: TextStyle(
                                  color: Color(0xFF1E3A8A),
                                ), // Navy Blue
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
