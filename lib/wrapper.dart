import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vistr_app/pages/admin/adminscreens/chome.dart';
import 'package:vistr_app/pages/splashscreens/splashscreen.dart';
import 'package:vistr_app/pages/user/screens/home.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool? isAdmin;
  String? building;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool adminStatus = await _isUserAdmin(user.email);
      if (adminStatus) {
        await _getAdminBuilding(user.email);
      }
      setState(() {
        isAdmin = adminStatus;
        isLoading = false;
      });
    } else {
      setState(() {
        isAdmin = false;
        isLoading = false;
      });
    }
  }

  Future<bool> _isUserAdmin(String? email) async {
    if (email == null) return false;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('admin')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _getAdminBuilding(String? email) async {
    if (email == null) return;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('admin')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        building = querySnapshot.docs.first['building'] ;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) {
      return SplashScreen();
    } else if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (isAdmin == true) {
      return cHome(building: building ?? "No Building");
    } else {
      return const Home();
    }
  }
}
