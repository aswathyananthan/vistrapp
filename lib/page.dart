import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vistr_app/pages/admin/adminscreens/chome.dart';
import 'package:vistr_app/pages/user/screens/home.dart';

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  bool isAdmin = true; // Toggle between admin and user
  String? building; // Store building name
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _getBuildingForCurrentAdmin(); // Fetch building data on startup
  }

  Future<void> _getBuildingForCurrentAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          setState(() {
            building = adminDoc['building']; // Get building from Firestore
            isLoading = false;
          });
        } else {
          setState(() {
            building = "No Building Assigned";
            isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching building: $e");
        setState(() {
          building = "Error Loading Building";
          isLoading = false;
        });
      }
    } else {
      setState(() {
        building = "User Not Logged In";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          Switch(
            value: isAdmin,
            onChanged: (value) {
              setState(() {
                isAdmin = value;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : isAdmin
              ? cHome(building: building ?? "No Building")
              : const Home(),
    );
  }
}
