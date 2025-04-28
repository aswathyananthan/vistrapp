
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistr_app/pages/admin/adminscreens/addbuilding.dart';
import 'package:vistr_app/pages/admin/adminscreens/notifications.dart';
import 'package:intl/intl.dart';
import 'package:vistr_app/pages/splashscreens/getstarted.dart';

class cHome extends StatefulWidget {
  final String building;
  const cHome({super.key, required this.building});

  @override
  State<cHome> createState() => _cHomeState();
}

class _cHomeState extends State<cHome> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<DocumentSnapshot> currentUsers = [];
  List<DocumentSnapshot> pastUsers = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print("Initializing cHome with building: ${widget.building}");
    fetchUsers();
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

  Future<void> fetchUsers() async {
    try {
      print("Fetching users for building: ${widget.building}");
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'approved')
          .where('building', isEqualTo: widget.building)
          .get();

      List<DocumentSnapshot> current = [];
      List<DocumentSnapshot> past = [];

      print("Fetched ${snapshot.docs.length} approved requests for ${widget.building}");
      for (var doc in snapshot.docs) {
        var user = doc.data() as Map<String, dynamic>;
        print("User: ${user['name']}, Building: ${user['building']}, CheckIn: ${user['checkInTime']}, CheckOut: ${user['checkOutTime']}");
        if (user.containsKey('checkInTime') && user['checkInTime'] != null) {
          if (user.containsKey('checkOutTime') && user['checkOutTime'] != null) {
            past.add(doc);
          } else {
            current.add(doc);
          }
        }
      }

      setState(() {
        currentUsers = current;
        pastUsers = past;
        print("Current Users: ${currentUsers.length}, Past Users: ${pastUsers.length}");
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching users: $e')));
      print("Error fetching users: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String formatDate(dynamic date) {
    if (date == null) return "N/A";
    try {
      if (date is Timestamp) {
        DateTime dateTime = date.toDate();
        return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
      } else if (date is String) {
        DateTime dateTime = DateTime.parse(date);
        return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
      }
    } catch (e) {
      return "Invalid Date";
    }
    return "Unknown";
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GetStarted()));
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Home",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminNotificationsPage(building: widget.building)));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade900, Colors.black.withOpacity(0.9)],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.tealAccent.shade700, Colors.teal.shade900],
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.business, size: 40, color: Colors.tealAccent.shade700),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.building,
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      "Admin Panel",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildDrawerItem(Icons.home, "Home", () => Navigator.pop(context), color: Colors.tealAccent.shade400),
              _buildDrawerItem(Icons.notifications, "Notifications", () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminNotificationsPage(building: widget.building)));
              }, color: Colors.tealAccent.shade400),
              _buildDrawerItem(Icons.logout, "Sign Out", () {
                Navigator.pop(context);
                _signOut();
              }, color: Colors.redAccent.shade400),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900, Colors.black.withOpacity(0.9)],
          ),
        ),
        child: _selectedIndex == 0 ? _buildCurrentUsers() : _buildPastUsers(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (context) => AddBuilding(buildingName: widget.building),
          ).then((_) => fetchUsers());
        },
        backgroundColor: Colors.tealAccent.shade700,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        elevation: 10,
        color: Colors.grey.shade900,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.person, "Current", 0),
            _buildNavItem(Icons.history, "Past", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _selectedIndex == index ? Colors.tealAccent.shade400 : Colors.white70,
              size: 24,
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _selectedIndex == index ? Colors.tealAccent.shade400 : Colors.white70,
                fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentUsers() {
    return RefreshIndicator(
      onRefresh: fetchUsers,
      color: Colors.tealAccent.shade400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Current Users",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: currentUsers.isEmpty
                ? Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_off, size: 60, color: Colors.white70),
                          const SizedBox(height: 10),
                          Text("No Current Users", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: currentUsers.length,
                    itemBuilder: (context, index) {
                      var user = currentUsers[index].data() as Map<String, dynamic>;
                      return FadeTransition(opacity: _fadeAnimation, child: _buildUserCard(user));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastUsers() {
    return RefreshIndicator(
      onRefresh: fetchUsers,
      color: Colors.tealAccent.shade400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Past Users",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: pastUsers.isEmpty
                ? Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_toggle_off, size: 60, color: Colors.white70),
                          const SizedBox(height: 10),
                          Text("No Past Users", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: pastUsers.length,
                    itemBuilder: (context, index) {
                      var user = pastUsers[index].data() as Map<String, dynamic>;
                      return FadeTransition(opacity: _fadeAnimation, child: _buildUserCard(user));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.tealAccent.shade400.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.tealAccent.shade700,
          child: user['img'] != null && user['img'].isNotEmpty
              ? ClipOval(child: Image.file(File(user['img']), width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person, color: Colors.white)))
              : Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          "Company: ${user['company'] ?? 'N/A'}",
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        ),
        trailing: Icon(Icons.arrow_drop_down, size: 24, color: Colors.white70), // Changed to dropdown arrow
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user['img'] != null && user['img'].isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(user['img']), width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container()),
                    ),
                  ),
                const SizedBox(height: 10),
                Text("Name: ${user['name'] ?? 'Unknown'}", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                Text("Company: ${user['company'] ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                Text("Check-in: ${formatDate(user['checkInTime'])}", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                if (user.containsKey('checkOutTime') && user['checkOutTime'] != null)
                  Text("Check-out: ${formatDate(user['checkOutTime'])}", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                Text("Email/Phone: ${user['emailorphone'] ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
        hoverColor: Colors.tealAccent.withOpacity(0.2),
      ),
    );
  }
}
