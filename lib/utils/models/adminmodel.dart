class Adminmodel {
  final String building;
  final String email;
  final List<String> companys; // List of companies under this admin

  Adminmodel({
    required this.building,
    required this.email,
    this.companys = const [], // Default to an empty list
  });

  Map<String, dynamic> toJSON() {
    return {
      "building": building,
      "email": email,
      "companys": companys, // Store the list of companies
    };
  }
}
