import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vistr_app/pages/splashscreens/getstarted.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key, this.userData});

  final Map<String, dynamic>? userData;

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> GetStarted()));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900, Colors.black.withOpacity(0.9)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  children: [
                    _buildDrawerItem(
                      Icons.home,
                      "Home",
                      () => Navigator.pop(context),
                      color: Colors.tealAccent.shade400,
                    ),
                    
                    _buildDrawerItem(
                      Icons.logout,
                      "Sign Out",
                      () {
                        
                        signOut(context);
                      },
                      color: Colors.redAccent.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.tealAccent.shade700, Colors.teal.shade900],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: FutureBuilder<User?>(
          future: getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildUserHeader(
                "Loading...",
                "Please wait",
                null,
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return _buildUserHeader(
                "No User",
                "Sign in to continue",
                null,
              );
            }

            User user = snapshot.data!;
            return _buildUserHeader(
              user.displayName ?? "Username",
              user.email ?? "No Email",
              user.photoURL,
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserHeader(String name, String email, String? photoUrl) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.tealAccent.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        errorBuilder: (context, error, stackTrace) => _buildInitialAvatar(email),
                      ),
                    )
                  : _buildInitialAvatar(email),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(String email) {
    return Text(
      email.isNotEmpty ? email.substring(0, 1).toUpperCase() : "?",
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.tealAccent.shade700,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        hoverColor: Colors.tealAccent.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
