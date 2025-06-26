import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [ 
                      SizedBox(height: 10,),
                      Text(
                      "SignUp",
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
                    FullNames(),
                    SizedBox(height: 20),
                    Email(),
                    SizedBox(height: 20),
                    Password(),
                    SizedBox(height: 20),
                    ConfirmPassword(),
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


class FullNames extends StatelessWidget {
  const FullNames({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 450, 
        child: TextFormField(
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
  const Email({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 450, 
        child: TextFormField(
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

class Password extends StatefulWidget {
  const Password({super.key});

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
              }, icon: Icon(
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

class ConfirmPassword extends StatefulWidget {
  const ConfirmPassword({super.key});

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
          obscureText: _isObscuredText,
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
              child: IconButton(onPressed: () {
              setState(() {
                _isObscuredText = !_isObscuredText;
              });
              }, 
              icon: Icon(
                _isObscuredText ? Icons.visibility_off : Icons.visibility,
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