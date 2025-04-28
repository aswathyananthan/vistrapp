


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationsPage extends StatefulWidget {
  final String building; // Admin's building
  AdminNotificationsPage({super.key, required this.building});

  @override
  _AdminNotificationsPageState createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRequest(String requestId, String status) async {
    try {
      if (status == "approved") {
        await _firestore.collection("requests").doc(requestId).update({"status": status});
      } else if (status == "rejected") {
        await _firestore.collection("requests").doc(requestId).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request $status successfully!"),
          backgroundColor: status == "approved" ? Colors.tealAccent.shade700 : Colors.redAccent.shade400,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.redAccent.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.tealAccent.shade700, Colors.teal.shade900],
            ),
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Text(
          "Admin Notifications",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900, Colors.black.withOpacity(0.9)],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection("requests").where("status", isEqualTo: "pending").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent.shade400),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 60,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "No New Notifications",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            var requests = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String requestBuilding = data["building"]?.toString().toLowerCase() ?? "";
              String adminBuilding = widget.building.toLowerCase();

              print("🔍 Request Building: ${data["building"]} - Expected: ${widget.building}"); // Debugging Log

              return requestBuilding == adminBuilding; // Only show if buildings match
            }).toList();

            if (requests.isEmpty) {
              print("⚠️ No requests match the admin's building.");
              return Center(
                child: Text(
                  "No New Notifications",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                var request = requests[index];
                String requestId = request.id;
                String name = request["name"];
                String emailOrPhone = request["emailorphone"];
                String company = request["company"];

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.tealAccent.shade400.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Visitor: $name",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Contact: $emailOrPhone",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "Company: $company",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _handleRequest(requestId, "approved"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.tealAccent.shade700,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 3,
                                shadowColor: Colors.tealAccent.withOpacity(0.5),
                              ),
                              child: Text(
                                "Approve",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _handleRequest(requestId, "rejected"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.shade400,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 3,
                                shadowColor: Colors.redAccent.withOpacity(0.5),
                              ),
                              child: Text(
                                "Reject",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
