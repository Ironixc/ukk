class UserModel {
  int? id;
  String? username;
  String? role;
  int? idPelanggan;
  String? nik;
  String? namaLengkap;

  UserModel({
    this.id, 
    this.username, 
    this.role, 
    this.idPelanggan,
    this.nik,
    this.namaLengkap
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Ambil data dari objek 'profile' jika ada
    var profile = json['profile'];
    
    return UserModel(
      id: int.tryParse(json['user_id'].toString()),
      username: json['username'],
      role: json['role'],
      idPelanggan: profile != null ? int.tryParse(profile['id'].toString()) : null,
      // Mapping NIK dan Nama dari Profile
      nik: profile != null ? profile['nik'] : '',
      namaLengkap: profile != null ? profile['nama_penumpang'] : '',
    );
  }
}