class Requestmodel {
  final String name;
  final String emailorphone;
  final String img;
  final String company;
  final bool ans;
  String status;
  String? checkInTime;
  String building;
  Requestmodel({
    required this.name,
    required this.emailorphone,
    required this.img,
    required this.company,
    required this.ans,
    this.status = "pending", // Default status
    this.checkInTime, 
    required this.building,
  });

  toJSON() {
    return {
      "name": name,
      "emailorphone": emailorphone,
      "img": img,
      "company": company,
      "ans": ans,
      "status": status,
      "checkInTime": checkInTime,
      "building": building
    };
  }
}
