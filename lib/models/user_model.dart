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
    var profile = json['profile'];
    
    return UserModel(
      id: int.tryParse(json['user_id'].toString()),
      username: json['username'],
      role: json['role'],
      idPelanggan: profile != null ? int.tryParse(profile['id'].toString()) : null,
      nik: profile != null ? (profile['nik'] ?? '') : '',
      // LOGIKA ADAPTASI: Cek nama_petugas (Admin) atau nama_penumpang (Pelanggan)
      namaLengkap: profile != null 
          ? (profile['nama_petugas'] ?? profile['nama_penumpang'] ?? 'User') 
          : 'User',
    );
  }
}