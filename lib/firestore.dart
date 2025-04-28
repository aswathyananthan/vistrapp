import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vistr_app/utils/models/adminmodel.dart';
import 'package:vistr_app/utils/models/companymodel.dart';
import 'package:vistr_app/utils/models/requestmodel.dart';
import 'package:vistr_app/utils/models/usermodel.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> readUsers() {
    return _firestore.collection("users").snapshots();
  }

  Future<void> writeUser(Usermodel user) async {
    try {
      await _firestore.collection("users").doc(user.name).set(user.toJSON());
    } catch (e) {
      throw Exception("Error writing user: ${e.toString()}");
    }
  }

  Future<void> writeAdmin(Adminmodel admin) async {
    try {
      await _firestore.collection("admin").doc(admin.building).set(admin.toJSON());
    } catch (e) {
      throw Exception("Error writing admin: ${e.toString()}");
    }
  }

  Future<void> addCompany(Companymodel company) async {
    try {
      await _firestore.collection("company").doc(company.cname).set(company.toJSON());
    } catch (e) {
      throw Exception("Error adding company: ${e.toString()}");
    }
  }

  Future<void> addCompanyToAdmin({
    required String buildingName,
    required String companyName,
  }) async {
    try {
      DocumentReference adminRef = _firestore.collection("admin").doc(buildingName);
      await adminRef.update({
        "companys": FieldValue.arrayUnion([companyName]),
      });
    } catch (e) {
      throw Exception("Error adding company to admin: ${e.toString()}");
    }
  }

  Future<String> addRequest(Requestmodel request) async {
  try {
    DocumentReference docRef = await _firestore.collection("requests").add(request.toJSON());
    return docRef.id; // Return the unique document ID
  } catch (e) {
    throw Exception("Error adding request: ${e.toString()}");
  }
}

  Future<void> addRequestToCompany({
    required String companyName,
    required String requestId,
  }) async {
    try {
      DocumentReference companyRef = _firestore.collection("company").doc(companyName);
      await companyRef.update({
        "requests": FieldValue.arrayUnion([requestId]),
      });
    } catch (e) {
      throw Exception("Error adding request to company: ${e.toString()}");
    }
  }
}