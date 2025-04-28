import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vistr_app/pages/user/screens/request.dart';
import 'package:vistr_app/pages/user/screens/virtual.dart';
import 'package:vistr_app/pages/user/screens/home.dart'; // Import home page

class RequestSubmittedPage extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> adminData;

  const RequestSubmittedPage({super.key, required this.requestId, required this.adminData});

  @override
  _RequestSubmittedPageState createState() => _RequestSubmittedPageState();
}

class _RequestSubmittedPageState extends State<RequestSubmittedPage> with SingleTickerProviderStateMixin {
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
    _checkRequestStatus();
    _animationController.forward();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkRequestStatus() async {
    FirebaseFirestore.instance.collection("requests").doc(widget.requestId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        String status = snapshot.data()?["status"] ?? "pending";

        if (status == "approved") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VirtualIdCardPage()),
          );
        } else if (status == "rejected") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RequestPage(admin: widget.adminData)),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900, Colors.black.withOpacity(0.9)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Lottie.asset(
                      "assets/loading.json",
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Request Submitted!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Waiting for approval...\nYou’ll be redirected once reviewed.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // CircularProgressIndicator(
                  //   valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent.shade400),
                  //   strokeWidth: 3,
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
