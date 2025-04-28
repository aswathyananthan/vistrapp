import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistr_app/firestore.dart';
import 'package:vistr_app/utils/models/companymodel.dart';

class AddBuilding extends StatefulWidget {
  final String buildingName;

  const AddBuilding({super.key, required this.buildingName});

  @override
  State<AddBuilding> createState() => _AddBuildingState();
}

class _AddBuildingState extends State<AddBuilding> with SingleTickerProviderStateMixin {
  final FirestoreServices _firestoreServices = FirestoreServices();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doorController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    doorController.dispose();
    floorController.dispose();
    super.dispose();
  }

  Future<void> _addCompany() async {
    setState(() => _isLoading = true);

    String cname = nameController.text.trim();
    String door = doorController.text.trim();
    String floor = floorController.text.trim();

    if (cname.isEmpty || door.isEmpty || floor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields!", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade400,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    Companymodel company = Companymodel(cname: cname, door: door, floor: floor);

    try {
      await _firestoreServices.addCompany(company);
      await _firestoreServices.addCompanyToAdmin(buildingName: widget.buildingName, companyName: cname);

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Company added successfully!", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.tealAccent.shade700,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding company: $e", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade900, Colors.black.withOpacity(0.9)],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Add Company to ${widget.buildingName}",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: nameController,
                    label: "Company Name",
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: doorController,
                    label: "Door No",
                    icon: Icons.door_front_door_outlined,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: floorController,
                    label: "Floor No",
                    icon: Icons.stairs_outlined,
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addCompany,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                        shadowColor: Colors.tealAccent.withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Add Company",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
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
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}