import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _confirmPasswordController = TextEditingController();

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
              password: _passwordController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'fullNames': _fullNamesController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign Up Successful!')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'An Error occurred. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF0C0F0A),
              Color(0xFF1EF813),
            ],
            stops: [0.03, 0.63],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 5),
              Center(
                child: Image.asset(
                  'logo/blacklogo.png',
                  width: 100,
                  height: 100,
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
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 490,
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
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
                          color: Colors.black,
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
                          color: Colors.black,
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
                          width: 450,
                          height: 40,
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
                                    Color(0xFF000000),
                                    Color(0xFF1EF813),
                                  ],
                                  stops: [0.0, 0.47],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                      )
                                    : const Text(
                                        'Sign Up',
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
                              color: Color(0xFF000000),
                              thickness: 1,
                              indent: 20,
                            ),
                          ),
                          Text(
                            "Or Sign Up With",
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFF000000),
                              thickness: 1,
                              endIndent: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: 450,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle Google sign up
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF1EF813), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Image.asset(
                                    'vectors/google.png',
                                    width: 22,
                                    height: 22,
                                  ),
                                ),
                                const Text(
                                  'Sign Up with Google',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Colors.black87,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 17,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  // Handle navigation to sign in page
                                },
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: Color(0xFF0F7709),
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

class FullNames extends StatelessWidget {
  final TextEditingController controller;
  const FullNames({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 450,
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
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintText: 'Enter Your Full Names',
            hintStyle: const TextStyle(
              color: Colors.black54,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.person,
                color: Colors.black,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          cursorColor: Color(0xFF1EF813),
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
        width: 450,
        child: TextFormField(
          controller: controller,
          validator: _validateEmail,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintText: 'Enter Your Email Address',
            hintStyle: const TextStyle(
              color: Colors.black54,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.mail,
                color: Colors.black,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          cursorColor: Color(0xFF1EF813),
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 450,
        child: TextFormField(
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
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintText: 'Enter Your Password',
            hintStyle: const TextStyle(
              color: Colors.black54,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.lock,
                color: Colors.black,
              ),
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
                  color: Colors.black54,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          cursorColor: Color(0xFF1EF813),
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
        width: 450,
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
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintText: 'Confirm Your Password',
            hintStyle: const TextStyle(
              color: Colors.black54,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.lock,
                color: Colors.black,
              ),
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
                  color: Colors.black54,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1EF813),
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          cursorColor: Color(0xFF1EF813),
        ),
      ),
    );
  }
}