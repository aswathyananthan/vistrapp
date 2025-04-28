import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistr_app/pages/user/login/signin.dart';
import 'package:vistr_app/pages/user/screens/home.dart';
import 'package:vistr_app/utils/auth/auth.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _signup() async {
    if (_formKey.currentState?.validate() == true) {
      try {
        final user = await _authService.signUpWithEmailAndPass(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': _emailController.text.trim(),
            'name': _nameController.text.trim(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup failed: User creation failed.')),
          );
        }
      } catch (e) {
        String errorMessage = 'Signup failed. Please try again.';
        if (e.toString().contains('invalid-email')) {
          errorMessage = 'The email address is badly formatted.';
        } else if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'This email is already registered.';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'Password is too weak.';
        } else if (e.toString().contains('permission-denied')) {
          errorMessage = 'Firestore permission denied.';
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
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Create Account",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Join us today",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildInputField(
                            "Name",
                            _nameController,
                            _validateName,
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 20),
                          _buildInputField(
                            "Confirm Password",
                            _confirmPasswordController,
                            _validateConfirmPassword,
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _signup,
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
                              "Sign Up",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        "Already have an account? ",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Signin()),
                          );
                        },
                        child: Text(
                          "Sign In",
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
