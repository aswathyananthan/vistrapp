import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistr_app/pages/user/login/signup.dart';
import 'package:vistr_app/pages/user/screens/home.dart';
import 'package:vistr_app/utils/auth/auth.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
        .hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _signin() async {
    if (_formKey.currentState?.validate() == true) {
      try {
        final user = await _authService.signInWithEmailAndPass(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign in successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign in failed: User not found.')),
          );
        }
      } catch (e) {
        String errorMessage = 'Sign in failed. Please try again.';
        if (e.toString().contains('invalid-email')) {
          errorMessage = 'The email address is badly formatted.';
        } else if (e.toString().contains('user-not-found')) {
          errorMessage = 'No user found with this email.';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect password.';
        } else if (e.toString().contains('invalid-credential')) {
          errorMessage = 'Invalid credentials provided.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.grey.shade900.withOpacity(0.9),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(30),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome Back",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Sign in to continue",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildInputField(
                          "Email",
                          _emailController,
                          _validateEmail,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          "Password",
                          _passwordController,
                          _validatePassword,
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _signin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                            shadowColor: Colors.tealAccent.withOpacity(0.5),
                          ),
                          child: Text(
                            "Sign In",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account? ",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Signup()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.tealAccent.shade400,
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
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String? Function(String?)? validator, {
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.tealAccent.shade400, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      validator: validator,
    );
  }
}
