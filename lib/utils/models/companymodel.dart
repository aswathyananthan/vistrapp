class Companymodel {
  final String cname;
  final String door;
  final String floor;
   final List<String> requests;

  Companymodel({
    required this.cname,
    required this.door,
    required this.floor,
    this.requests = const [],
  });
  toJSON() {
    return {
      "cname": cname,
      "door": door,
      "floor": floor,
      "requests": requests,
    };
  }
}
