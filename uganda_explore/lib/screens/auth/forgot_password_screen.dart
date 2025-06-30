import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
            colors: [Color(0xFF0C0F0A), Color(0xFF1EF813)],
            stops: [0.03, 0.63],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  'assets/logo/blacklogo.png',
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
  child: Column(
    children: const [
      SizedBox(height: 30),
      // Form elements will go here
    ],
  ),
),

          ],
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
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1EF813),
      ),
      child: const Icon(
        Icons.lock_reset,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}

class NewPasswordField extends StatefulWidget {
  const NewPasswordField({super.key});

  @override
  State<NewPasswordField> createState() => _NewPasswordFieldState();
}

class _NewPasswordFieldState extends State<NewPasswordField> {
  bool _isObscured = true;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      child: TextFormField(
        controller: _controller,
        obscureText: _isObscured,
        decoration: InputDecoration(
          labelText: 'New Password',
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          ),
        ),
      ),
    );
  }
}

class ChangePasswordButton extends StatelessWidget {
  const ChangePasswordButton({super.key});

  void _onPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Your password has been changed successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/signin');
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onPressed(context),
      child: Container(
        width: 450,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 47, 44, 44), Color(0xFF1EF813)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
