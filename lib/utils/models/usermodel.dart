// class Usermodel {
//   final String name;
//   final String email;

//   Usermodel({
//     required this.name,
//     required this.email,
//   });
//   toJSON() {
//     return {
//       "name": name,
//       "email": email,
//     };
//   }
// }


class Usermodel {
  final String id;
  final String name;
  final String email;
  final List<String> requests;

  Usermodel({
    required this.id,
    required this.name,
    required this.email,
    this.requests = const [],
  });

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "requests": requests,
    };
  }
}
