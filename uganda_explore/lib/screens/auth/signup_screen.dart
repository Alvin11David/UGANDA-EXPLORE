import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uganda_explore/screens/auth/sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNamesController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'fullNames': _fullNamesController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': userCredential.user!.email,
            'fullNames': _fullNamesController.text
                .trim(), // from your sign up form
            // ...other fields
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign Up Successful!')));

      // Check if the user is admin
      if (_emailController.text.trim().toLowerCase() == 'admin@gmail.com') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding_screen1');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } catch (e) {
      setState(() {
        _errorMessage = 'An Error occurred. Please try again.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNamesController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ], // Navy to blue gradient
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Center(
                child: Image.asset(
                  'assets/logo/whitelogo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Let's get you\n signed up!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 37,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 490,
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "SignUp",
                        style: TextStyle(
                          color: Color(0xFF1E3A8A), // Navy blue
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Please enter the details to continue.",
                        style: TextStyle(
                          color: Color(0xFF6B7280), // Gray
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FullNames(controller: _fullNamesController),
                      const SizedBox(height: 20),
                      Email(controller: _emailController),
                      const SizedBox(height: 20),
                      Password(controller: _passwordController),
                      const SizedBox(height: 20),
                      ConfirmPassword(
                        controller: _confirmPasswordController,
                        passwordController: _passwordController,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 320,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1E3A8A), // Navy blue
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFE5E7EB), // Light gray
                              thickness: 1,
                              indent: 20,
                            ),
                          ),
                          Text(
                            "Or Sign Up With",
                            style: TextStyle(
                              color: Color(0xFF6B7280), // Gray
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFFE5E7EB), // Light gray
                              thickness: 1,
                              endIndent: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Google Sign Up button removed
                      const SizedBox(height: 18),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Color(0xFF6B7280), // Gray
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 17,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignInScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6), // Blue accent
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    decorationThickness: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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

class Password extends StatefulWidget {
  final TextEditingController controller;
  const Password({super.key, required this.controller});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  bool _isObscured = true;
  double _strength = 0;

  String get _strengthLabel {
    if (_strength < 0.4) return 'Weak';
    if (_strength < 0.7) return 'Good';
    return 'Strong';
  }

  Color get _strengthLabelColor {
    if (_strength < 0.4) return Color(0xFFEF4444); // Red
    if (_strength < 0.7) return Color(0xFFF59E0B); // Orange
    return Color(0xFF10B981); // Green
  }

  double _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 6) strength += 0.3;
    if (password.length >= 8) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;
    return strength.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength < 0.4) return Color(0xFFEF4444); // Red
    if (strength < 0.7) return Color(0xFFF59E0B); // Orange
    return Color(0xFF10B981); // Green
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: widget.controller,
              obscureText: _isObscured,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _strength = _calculateStrength(value);
                });
              },
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(
                  color: Color(0xFF374151), // Dark gray
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                hintText: 'Enter Your Password',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF), // Light gray
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.lock, color: Color(0xFF6B7280)), // Gray
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFF9CA3AF), // Light gray
                    ),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB), // Light gray
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6), // Blue
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444), // Red
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444), // Red
                    width: 2,
                  ),
                ),
                errorStyle: const TextStyle(
                  color: Color(0xFFEF4444), // Red
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
                color: Color(0xFF374151), // Dark gray
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
              cursorColor: Color(0xFF3B82F6), // Blue
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 910,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: _strength,
                  minHeight: 5,
                  backgroundColor: Color(0xFFE5E7EB), // Light gray
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStrengthColor(_strength),
                  ),
                ),
              ),
            ),
            // Show label only when user types
            if (widget.controller.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1.0, left: 2.0),
                child: Text(
                  _strengthLabel,
                  style: TextStyle(
                    color: _strengthLabelColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullNames extends StatelessWidget {
  final TextEditingController controller;
  const FullNames({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter your full names';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Full Names',
            labelStyle: const TextStyle(
              color: Color(0xFF374151), // Dark gray
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintText: 'Enter Your Full Names',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF), // Light gray
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.person, color: Color(0xFF6B7280)), // Gray
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB), // Light gray
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6), // Blue
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444), // Red
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444), // Red
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFEF4444), // Red
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
            color: Color(0xFF374151), // Dark gray
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
              color: Color(0xFF374151), // Dark gray
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintText: 'Enter Your Email Address',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF), // Light gray
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.mail, color: Color(0xFF6B7280)), // Gray
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB), // Light gray
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6), // Blue
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444), // Red
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444), // Red
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFEF4444), // Red
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
            color: Color(0xFF374151), // Dark gray
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

class ConfirmPassword extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;
  const ConfirmPassword({
    super.key,
    required this.controller,
    required this.passwordController,
  });

  @override
  State<ConfirmPassword> createState() => _ConfirmPasswordState();
}

class _ConfirmPasswordState extends State<ConfirmPassword> {
  bool _isObscuredText = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: TextFormField(
          controller: widget.controller,
          obscureText: _isObscuredText,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please confirm your password';
            }
            if (value != widget.passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            labelStyle: const TextStyle(
              color: Color(0xFF374151), // Dark gray
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintText: 'Confirm Your Password',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF), // Light gray
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.lock, color: Color(0xFF6B7280)), // Gray
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isObscuredText = !_isObscuredText;
                  });
                },
                icon: Icon(
                  _isObscuredText ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF9CA3AF), // Light gray
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB), // Light gray
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6), // Blue
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444), // Red
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444), // Red
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFEF4444), // Red
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
            color: Color(0xFF374151),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          cursorColor: Color(0xFF3B82F6),
        ),
      ),
    );
  }
}
