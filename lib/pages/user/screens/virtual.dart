import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VirtualIdCardPage extends StatefulWidget {
  const VirtualIdCardPage({super.key});

  @override
  State<VirtualIdCardPage> createState() => _VirtualIdCardPageState();
}

class _VirtualIdCardPageState extends State<VirtualIdCardPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkIn(String docId) async {
    try {
      await _firestore.collection('requests').doc(docId).update({
        'checkInTime': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Checked in successfully!",
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Check-in failed: ${e.toString()}",
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _checkOut(String docId) async {
    try {
      await _firestore.collection('requests').doc(docId).update({
        'checkOutTime': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Checked out successfully!",
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Check-out failed: ${e.toString()}",
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Please log in to view your ID card',
              style: GoogleFonts.poppins(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.tealAccent.shade700, Colors.teal.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text("Digital ID Card",
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey.shade900, Colors.black87],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 450,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('requests')
                      .where('emailorphone', isEqualTo: user.email)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildErrorMessage("No ID cards available");
                    }

                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var request = snapshot.data!.docs[index];
                          Map<String, dynamic> requestData =
                              request.data() as Map<String, dynamic>;
                          return _buildContent(request.id, requestData);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String docId, Map<String, dynamic> requestData) {
    String? status = requestData['status'] as String?;
    bool hasCheckedIn = requestData['checkInTime'] != null;
    bool hasCheckedOut = requestData['checkOutTime'] != null;
    Timestamp? checkInTimestamp = requestData['checkInTime'];
    Timestamp? checkOutTimestamp = requestData['checkOutTime'];

    if (status == 'rejected') {
      return _buildRejectedCard();
    }

    return Container(
      width: 280, // Reduced from 340
      margin: const EdgeInsets.all(16), // Reduced from 20
      padding: const EdgeInsets.all(16), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20), // Slightly reduced from 24
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15, // Reduced from 20
            offset: const Offset(0, 8), // Reduced from 10
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImage(requestData['img']),
            const SizedBox(height: 16), // Reduced from 20
            Text(
              requestData['name'] ?? 'Unknown',
              style: GoogleFonts.poppins(
                fontSize: 20, // Reduced from 24
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade900,
              ),
            ),
            Text(
              "Visitor Pass",
              style: GoogleFonts.poppins(
                fontSize: 14, // Reduced from 16
                color: Colors.teal.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16), // Reduced from 20
            _buildInfoCard(requestData),
            const SizedBox(height: 16), // Reduced from 20
            _buildActionButton(docId, status, hasCheckedIn, hasCheckedOut),
            if (hasCheckedIn) ...[
              const SizedBox(height: 12), // Reduced from 16
              _buildTimestampRow("Checked In",
                  checkInTimestamp?.toDate().toString().substring(0, 16)),
            ],
            if (hasCheckedOut) ...[
              const SizedBox(height: 6), // Reduced from 8
              _buildTimestampRow("Checked Out",
                  checkOutTimestamp?.toDate().toString().substring(0, 16)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? imagePath) {
    return Container(
      padding: const EdgeInsets.all(3), // Reduced from 4
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.teal.shade300, Colors.teal.shade700],
        ),
      ),
      child: CircleAvatar(
        radius: 45, // Reduced from 60
        backgroundColor: Colors.white,
        child: ClipOval(
          child: imagePath != null && imagePath.isNotEmpty
              ? Image.file(
                  File(imagePath),
                  width: 84, // Reduced from 110
                  height: 84, // Reduced from 110
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: 45, // Reduced from 60
                    color: Colors.teal.shade700,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 45, // Reduced from 60
                  color: Colors.teal.shade700,
                ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> requestData) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced from 16
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12), // Reduced from 16
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        children: [
          _buildInfoRow(
              Icons.email, "Contact", requestData['emailorphone'] ?? ''),
          const SizedBox(height: 8), // Reduced from 12
          _buildInfoRow(
              Icons.business, "Company", requestData['company'] ?? ''),
          const SizedBox(height: 8), // Reduced from 12
          _buildInfoRow(
              Icons.location_on, "Building", requestData['building'] ?? ''),
          const SizedBox(height: 8), // Reduced from 12
          _buildInfoRow(Icons.health_and_safety, "Screening",
              requestData['ans'] == true ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.teal.shade700), // Reduced from 20
        const SizedBox(width: 8), // Reduced from 12
        Text(
          "$label: ",
          style: GoogleFonts.poppins(
            fontSize: 12, // Reduced from 14
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12, // Reduced from 14
              color: Colors.blueGrey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.access_time,
            size: 14, color: Colors.teal.shade700), // Reduced from 16
        const SizedBox(width: 6), // Reduced from 8
        Text(
          "$label: ${value ?? ''}",
          style: GoogleFonts.poppins(
            fontSize: 10, // Reduced from 12
            color: Colors.blueGrey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String docId, String? status, bool hasCheckedIn, bool hasCheckedOut) {
    if (hasCheckedOut) {
      return Container(
        padding: const EdgeInsets.symmetric(
            vertical: 6, horizontal: 12), // Reduced from 8,16
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16), // Reduced from 20
        ),
        child: Text(
          "Visit Completed",
          style: GoogleFonts.poppins(
            fontSize: 12, // Reduced from 14
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
      );
    }

    if (hasCheckedIn) {
      return ElevatedButton(
        onPressed: () => _checkOut(docId),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade700,
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 10), // Reduced from 32,12
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)), // Reduced from 30
          elevation: 3, // Reduced from 4
        ),
        child: Text(
          "Check Out",
          style: GoogleFonts.poppins(
            fontSize: 14, // Reduced from 16
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    if (status == 'approved') {
      return ElevatedButton(
        onPressed: () => _checkIn(docId),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade700,
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 10), // Reduced from 32,12
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)), // Reduced from 30
          elevation: 3, // Reduced from 4
        ),
        child: Text(
          "Check In",
          style: GoogleFonts.poppins(
            fontSize: 14, // Reduced from 16
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 6, horizontal: 12), // Reduced from 8,16
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16), // Reduced from 20
      ),
      child: Text(
        "Pending Approval",
        style: GoogleFonts.poppins(
          fontSize: 12, // Reduced from 14
          fontWeight: FontWeight.w600,
          color: Colors.orange.shade800,
        ),
      ),
    );
  }

  Widget _buildRejectedCard() {
    return Container(
      width: 280, // Reduced from 340
      margin: const EdgeInsets.all(16), // Reduced from 20
      padding: const EdgeInsets.all(16), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20), // Reduced from 24
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15, // Reduced from 20
            offset: const Offset(0, 8), // Reduced from 10
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block,
              size: 50, color: Colors.red.shade700), // Reduced from 60
          const SizedBox(height: 16), // Reduced from 20
          Text(
            "Request Rejected",
            style: GoogleFonts.poppins(
              fontSize: 20, // Reduced from 24
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade900,
            ),
          ),
          const SizedBox(height: 8), // Reduced from 12
          Text(
            "Your request was rejected. Please submit a new request.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14, // Reduced from 16
              color: Colors.blueGrey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Container(
        width: 280, // Reduced from 340
        padding: const EdgeInsets.all(16), // Reduced from 24
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20), // Reduced from 24
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15, // Reduced from 20
              offset: const Offset(0, 8), // Reduced from 10
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 50, color: Colors.red.shade700), // Reduced from 60
            const SizedBox(height: 16), // Reduced from 20
            Text(
              "No ID Card Available",
              style: GoogleFonts.poppins(
                fontSize: 20, // Reduced from 24
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade900,
              ),
            ),
            const SizedBox(height: 8), // Reduced from 12
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14, // Reduced from 16
                color: Colors.blueGrey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




      // Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //       colors: [Colors.blueGrey.shade900, Colors.black87],
      //     ),
      //   ),