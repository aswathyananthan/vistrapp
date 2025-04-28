import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistr_app/pages/user/screens/drawer.dart';
import 'package:vistr_app/pages/user/screens/request.dart';
import 'package:vistr_app/pages/user/screens/virtual.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> adminList = [];
  List<Map<String, dynamic>> filteredList = [];
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    fetchAdminData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAdminData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("admin").get();
      List<Map<String, dynamic>> data = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        adminList = data;
        filteredList = data;
      });
    } catch (e) {
      print("Error fetching admin data: $e");
    }
  }

  void filterSearch(String query) {
    List<Map<String, dynamic>> results = [];
    if (query.isEmpty) {
      results = adminList;
    } else {
      results = adminList.where((admin) {
        return admin["building"]?.toLowerCase().contains(query.toLowerCase()) ?? false;
      }).toList();
    }

    setState(() {
      filteredList = results;
    });
  }

  void navigateToRequestPage(Map<String, dynamic> admin) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestPage(admin: admin)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Choose a Building',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VirtualIdCardPage()));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: const DrawerPage(),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterSearch,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search buildings...",
                      hintStyle: GoogleFonts.poppins(color: Colors.white70),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.tealAccent.shade400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.tealAccent.shade400, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.white70),
                            const SizedBox(height: 10),
                            Text(
                              "No matching buildings found",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final admin = filteredList[index];
                          return GestureDetector(
                            onTap: () => navigateToRequestPage(admin),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.tealAccent.shade700,
                                    child: const Icon(Icons.business, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          admin["building"] ?? "No Name",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "Tap to request access",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, color: Colors.tealAccent.shade400, size: 18),
                                ],
                              ),
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
}