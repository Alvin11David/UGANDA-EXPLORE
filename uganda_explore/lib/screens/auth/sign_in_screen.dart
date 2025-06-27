import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/logo/blacklogo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  )
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Let's get you\n signed in!",
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [ 
                    SizedBox(height: 10,),
                    Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Please enter the details to continue.",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    EmailField(),
                    SizedBox(height: 20),
                    PasswordField(),
                    SizedBox(height: 10),
                    ForgotPasswordLink(),
                    SizedBox(height: 20),
                    SignInButton(),
                    SizedBox(height: 20),
                    OrDivider(),
                    SizedBox(height: 16),
                    GoogleSignInButton(),
                    SizedBox(height: 20),
                    SignUpLink(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailField extends StatefulWidget {
  const EmailField({super.key});

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 450, 
        child: TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintText: 'Enter Your Email',
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

class PasswordField extends StatefulWidget {
  const PasswordField({super.key});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 450, 
        child: TextFormField(
          controller: _passwordController,
          obscureText: _isObscured,
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
              )
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
    );
  }
}

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          // Handle forgot password
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  void _onSignInPressed(BuildContext context) {
    // You'll need to implement your authentication logic here
    // For now, just navigate to home
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 450,
        child: GestureDetector(
          onTap: () => _onSignInPressed(context),
          child: Container(
            height: 50,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.00, 0.25),
                end: Alignment(1.00, 0.25),
                colors: [Color.fromARGB(255, 47, 44, 44), Color(0xFF1EF813)],
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
              'Sign In',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Colors.grey)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Or Sign In With',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: Colors.grey)),
        ],
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 450,
        child: GestureDetector(
          onTap: () {
            // Handle Google sign in
          },
          child: Container(
            height: 50,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFF1EF813),
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0xA5000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.g_translate,
                  color: Colors.black,
                  size: 24,
                ),
                SizedBox(width: 15),
                Text(
                  'Sign In with Google',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpLink extends StatelessWidget {
  const SignUpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/signup');
        },
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Don\'t have an account? ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: const Color(0xFF0F7709),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}