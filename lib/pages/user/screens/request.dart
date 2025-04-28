import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:vistr_app/firestore.dart';
import 'package:vistr_app/pages/user/screens/submit.dart';
import 'package:vistr_app/utils/models/requestmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestPage extends StatefulWidget {
  final Map<String, dynamic> admin;
  final Map<String, dynamic>? userData;

  const RequestPage({super.key, required this.admin, this.userData});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirestoreServices _firestoreServices = FirestoreServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? selectedCompany;
  bool? screeningAnswer;
  File? _visitorImage;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

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
    _autofillUserData();
    _initializeCamera();
    _animationController.forward();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      // Explicitly select the front camera
      CameraDescription? frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No front camera available")),
          );
          return _cameras.first; // Fallback to rear if no front camera
        },
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );

      try {
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error initializing camera: ${e.toString()}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No cameras available on this device")),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _autofillUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            nameController.text = userData['name'] ?? '';
            emailController.text = userData['email'] ?? currentUser.email ?? '';
          });
        } else if (currentUser.displayName != null ||
            currentUser.email != null) {
          setState(() {
            nameController.text = currentUser.displayName ?? '';
            emailController.text = currentUser.email ?? '';
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          nameController.text = currentUser.displayName ?? '';
          emailController.text = currentUser.email ?? '';
        });
      }
    } else if (widget.userData != null) {
      setState(() {
        nameController.text = widget.userData!['name'] ?? '';
        emailController.text = widget.userData!['email'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera not initialized")),
      );
      return;
    }

    try {
      if (!_cameraController!.value.isTakingPicture) {
        final XFile image = await _cameraController!.takePicture();
        setState(() {
          _visitorImage = File(image.path);
        });
        Navigator.pop(context); // Close the camera preview
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing image: ${e.toString()}")),
      );
    }
  }

  void _showCameraPreview() {
    if (_isCameraInitialized) {
      showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Expanded(
                child: CameraPreview(_cameraController!),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    "Capture",
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
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera not available")),
      );
    }
  }

  Future<void> _addRequest() async {
    if (!_formKey.currentState!.validate() || selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields!")),
      );
      return;
    }

    if (_visitorImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please capture a photo!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String name = nameController.text.trim();
    String emailOrPhone = emailController.text.trim();
    bool finalScreeningAnswer = screeningAnswer ?? false;
    String buildingValue = widget.admin["building"] ?? "No Name";

    Requestmodel request = Requestmodel(
      name: name,
      emailorphone: emailOrPhone,
      img: _visitorImage!.path,
      company: selectedCompany!,
      ans: finalScreeningAnswer,
      building: buildingValue,
      status: "pending",
    );

    try {
      await _firestoreServices.addRequest(request);
      await _firestoreServices.addRequestToCompany(
        companyName: selectedCompany!,
        requestId: request.name,
      );

      // ScaffoldMessenger.of(context).showSnackBar(
      //   // const SnackBar(content: Text("Request submitted successfully!")),
      // );

      _formKey.currentState!.reset();
      nameController.clear();
      emailController.clear();
      setState(() {
        _visitorImage = null;
        screeningAnswer = null;
        selectedCompany = null;
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestSubmittedPage(
            requestId: request.name,
            adminData: widget.admin,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> companies = List<String>.from(widget.admin["companys"] ?? []);

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
          "Visitor Request Form",
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Visiting: ${widget.admin["building"] ?? "No Name"}",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Please fill out the form below",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                          "Full Name",
                          nameController,
                          Icons.person_outline,
                          (value) =>
                              value!.isEmpty ? "Please enter your name" : null),
                      const SizedBox(height: 20),
                      _buildTextField(
                          "Email or Phone Number",
                          emailController,
                          Icons.email_outlined,
                          (value) => value!.isEmpty
                              ? "Please enter contact details"
                              : null),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                          "Company / Door to Visit",
                          companies,
                          selectedCompany,
                          (value) => setState(() => selectedCompany = value),
                          (value) =>
                              value == null ? "Please select a company" : null),
                      const SizedBox(height: 30),
                      Text(
                        "Have you had a fever, cough, or sore throat in the past 5 days?",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRadioTile("Yes", true),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildRadioTile("No", false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showCameraPreview,
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              label: Text(
                                "Capture Photo",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.tealAccent.shade700,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                elevation: 5,
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                      if (_visitorImage != null) ...[
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: Colors.tealAccent.shade400, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(_visitorImage!,
                                  width: 200, height: 150, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 5,
                            shadowColor: Colors.tealAccent.withOpacity(0.5),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  "Submit Request",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
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
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, String? Function(String?)? validator) {
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value,
      void Function(String?) onChanged, String? Function(String?)? validator) {
    return DropdownButtonFormField<String>(
      value: value,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        prefixIcon: const Icon(Icons.business, color: Colors.white70),
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      dropdownColor: Colors.grey.shade800,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child:
                    Text(item, style: GoogleFonts.poppins(color: Colors.white)),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildRadioTile(String title, bool value) {
    return RadioListTile<bool>(
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
      value: value,
      groupValue: screeningAnswer,
      onChanged: (newValue) => setState(() => screeningAnswer = newValue),
      activeColor: Colors.tealAccent.shade400,
      tileColor: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
