import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistr_app/pages/admin/login/adminin.dart';
import 'package:vistr_app/pages/user/login/signin.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(70),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900, Colors.black.withOpacity(0.9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Welcome!",
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.tealAccent.shade400.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Choose your role to get started",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildRoleButton(
                  context: context,
                  icon: Icons.person_outline,
                  label: "Visitor",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Signin())),
                ),
              ),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildRoleButton(
                  context: context,
                  icon: Icons.business,
                  label: "Company",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Login())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.tealAccent.shade700.withOpacity(0.2), Colors.teal.shade900.withOpacity(0.2)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.tealAccent.shade400.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.tealAccent.shade400),
            const SizedBox(width: 15),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}