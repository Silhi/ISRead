class UserModel {
  final String id;
  final String username;
  final String nrp;
  final String email;
  final String password;
  final String no_telpon;
  final String role;

  UserModel(
      {required this.id,
      required this.username,
      required this.nrp,
      required this.email,
      required this.password,
      required this.no_telpon,
      required this.role});

  factory UserModel.fromJson(Map data) {
    return UserModel(
        id: data['_id'],
        username: data['username'],
        nrp: data['nrp'],
        email: data['email'],
        password: data['password'],
        no_telpon: data['no_telpon'],
        role: data['role']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nrp': nrp,
      'email': email,
      'password': password,
      'no_telpon': no_telpon,
      'role': role,
    };
  }
}
