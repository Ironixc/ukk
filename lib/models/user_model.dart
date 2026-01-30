class UserModel {
  int? id;
  String? username;
  String? role;
  String? token;
  int? idPelanggan;

  UserModel({this.id, this.username, this.role, this.token, this.idPelanggan});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // --------------------------------------------------------
      // PERBAIKAN: Gunakan int.parse(...) agar String jadi Angka
      // --------------------------------------------------------
      
      // Mengubah "65" menjadi 65
      id: int.tryParse(json['user_id'].toString()), 
      
      username: json['username'],
      role: json['role'],
      
      // Mengubah ID Profile ("33") menjadi angka 33
      idPelanggan: json['profile'] != null 
          ? int.tryParse(json['profile']['id'].toString()) 
          : null,
    );
  }
}