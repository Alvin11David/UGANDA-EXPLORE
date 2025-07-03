import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  const ChangePasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  double _strength = 0;
  String _passwordStrengthLabel = '';
  Color _strengthColor = Colors.red;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    String label = 'Weak';
    Color color = Colors.red;

    if (password.length >= 6) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~._-]').hasMatch(password)) strength += 0.25;

    if (strength == 1) {
      label = 'Strong';
      color = Colors.green;
    } else if (strength >= 0.75) {
      label = 'Good';
      color = Colors.lightGreen;
    } else if (strength >= 0.5) {
      label = 'Medium';
      color = Colors.orange;
    }

    setState(() {
      _strength = strength;
      _passwordStrengthLabel = label;
      _strengthColor = color;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Include at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Include at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include at least one number';
    if (!RegExp(r'[!@#\$&*~._-]').hasMatch(value)) return 'Include at least one special character';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _onChangePasswordPressed() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Your password has been changed successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushReplacementNamed(context, '/signin'); // Navigate to sign in
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
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
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/logo/blacklogo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Let's get you\n sorted!",
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
                      const SizedBox(height: 20),
                      const PasswordResetIcon(),
                      const SizedBox(height: 20),
                      const Text(
                        "Reset Your Password",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Create a new password for your\naccount below.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // New Password Field with strength bar
                      Center(
                        child: SizedBox(
                          width: 320,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _isObscured,
                            onChanged: _checkPasswordStrength,
                            validator: _validatePassword,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              labelStyle: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              hintText: 'Enter Your New Password',
                              hintStyle: const TextStyle(
                                color: Colors.black54,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 6),
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
                      ),
                      // Password Strength Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _strength,
                              backgroundColor: Colors.white,
                              color: _strengthColor,
                              minHeight: 6,
                            ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _passwordStrengthLabel,
                              style: TextStyle(
                                color: _strengthColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Confirm Password Field
                      Center(
                        child: SizedBox(
                          width: 320,
                          child: TextFormField(
                            controller: _confirmController,
                            obscureText: _isConfirmObscured,
                            validator: _validateConfirmPassword,
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
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.lock_outline,
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
                                      _isConfirmObscured = !_isConfirmObscured;
                                    });
                                  },
                                  icon: Icon(
                                    _isConfirmObscured ? Icons.visibility_off : Icons.visibility,
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
                      ),
                      const SizedBox(height: 30),
                      // Change Password Button
                      Center(
                        child: SizedBox(
                          width: 320,
                          child: GestureDetector(
                            onTap: _onChangePasswordPressed,
                            child: Container(
                              height: 50,
                              decoration: ShapeDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color.fromARGB(255, 47, 44, 44),
                                    Color(0xFF1EF813)
                                  ],
                                  stops: [0.0, 0.47],
                                ),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFF1EF813),
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x3F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const BackToSignInLink(),
                      const SizedBox(height: 30),
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

class PasswordResetIcon extends StatelessWidget {
  const PasswordResetIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1EF813),
      ),
      child: const Icon(
        Icons.lock,
        color: Colors.white,
        size: 50,
      ),
    );
  }
}

class BackToSignInLink extends StatelessWidget {
  const BackToSignInLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
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
                style: TextStyle(color: Colors.black),
              ),
              const TextSpan(
                text: "Sign In",
                style: TextStyle(color: Color(0xFF0F7709)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}