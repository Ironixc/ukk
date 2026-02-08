import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user_model.dart'; 

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  UserModel? _currentUser; // Menggunakan Model, bukan variabel terpisah

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;

  // ---------------------------------------------------------------------------
  // 1. LOGIC REGISTER (BARU)
  // Menerima semua data sesuai tabel 'pelanggan' & 'users'
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String nik,
    required String namaPenumpang, // Sesuai kolom nama_penumpang
    required String alamat,
    required String telp,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/register.php');

      // DEBUG: Print data yang dikirim agar bisa dicek di Console
      print("Sending Data to $url");

      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
          'nik': nik,
          'nama_penumpang':
              namaPenumpang,
          'alamat': alamat,
          'telp': telp,
        },
      );

      final data = json.decode(response.body);

      _isLoading = false;
      notifyListeners();

      // Kembalikan map hasil respon (status & message) ke UI
      return data;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'status': 'error', 'message': 'Koneksi Error: $e'};
    }
  }

  // ---------------------------------------------------------------------------
  // 2. LOGIC LOGIN (PERBAIKAN)
  // ---------------------------------------------------------------------------
  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/login.php');

      // 1. Cek URL dan Data yang dikirim
      print("------------------------------------------------");
      print("Mencoba Login ke: $url");
      print("Mengirim Username: $identifier");
      print("Mengirim Password: $password");

      final response = await http.post(
        url,
        body: {
          'username': identifier, 
          'password': password,
        },
      );

      // 2. Cek Apa Balasan Server
      print("Status Code: ${response.statusCode}");
      print("Respon Server: ${response.body}"); 
      print("------------------------------------------------");

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        // ... (Kode simpan session Anda ...)
        _currentUser = UserModel.fromJson(data['data']);
        // ...
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("ERROR KONEKSI: $e"); 
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
// 3. LOGIC LOGOUT
  // Membersihkan sesi dari HP
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    // 1. Hapus data dari Memori Aplikasi (State)
    _currentUser = null;
    _isLoading = false;

    // 2. Hapus data dari Penyimpanan HP (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    
    // Opsi A: Hapus semua data (Paling Aman & Bersih)
    await prefs.clear(); 
    
    // Opsi B: Jika ingin menghapus spesifik saja (pilih salah satu opsi)
    // await prefs.remove('role');
    // await prefs.remove('userId');
    // await prefs.remove('profileId');

    // 3. Kabari UI bahwa user sudah keluar
    notifyListeners();
  }
//  // Update Profile dengan Debugging
//   Future<Map<String, dynamic>> updateProfile(String nama, String alamat, String telp) async {
//     try {
//       final url = Uri.parse('$baseUrl/update_profile.php');
      
//       // 1. DEBUG: Cek data yang mau dikirim
//       print("--------------------------------");
//       print("Mencoba Update Profile...");
//       print("ID User: ${_currentUser?.id}");
//       print("Data: Nama=$nama, Alamat=$alamat, Telp=$telp");

//       final response = await http.post(
//         url,
//         body: json.encode({
//           'id_user': _currentUser!.id, // Pastikan ini tidak null
//           'nama': nama,
//           'alamat': alamat,
//           'telp': telp,
//         }),
//       );

//       // 2. DEBUG: Cek balasan server
//       print("Status Code: ${response.statusCode}");
//       print("Response Body: ${response.body}");
//       print("--------------------------------");

//       final data = json.decode(response.body);

//       if (data['status'] == 'success') {
//         // Update data lokal di aplikasi agar langsung berubah tanpa login ulang
//         _currentUser!.namaLengkap = nama;
//         // Jika Anda punya field alamat/telp di UserModel, update juga disini
//         // _currentUser!.alamat = alamat; 
        
//         notifyListeners();
//         return {'success': true, 'message': 'Profil berhasil diperbarui'};
//       } else {
//         // Kembalikan pesan error asli dari PHP
//         return {'success': false, 'message': data['message'] ?? 'Gagal update'};
//       }
//     } catch (e) {
//       print("Error Update Profile: $e");
//       return {'success': false, 'message': 'Error Koneksi: $e'};
//     }
//   }
//   // --- TAMBAHKAN KODE INI DI DALAM CLASS AUTH PROVIDER ---

//   Future<String> changePassword(String oldPass, String newPass) async {
//     try {
//       final url = Uri.parse('$baseUrl/change_password.php');
      
//       final response = await http.post(
//         url,
//         body: json.encode({
//           'id_user': _currentUser!.id, // Ambil ID user yang sedang login
//           'old_password': oldPass,
//           'new_password': newPass,
//         }),
//       );

//       final data = json.decode(response.body);
      
//       // Kembalikan pesan dari server (Misal: "Password berhasil diganti" atau "Password lama salah")
//       if (data['message'] != null) {
//         return data['message'];
//       } else {
//         return "Terjadi kesalahan server";
//       }

//     } catch (e) {
//       return "Gagal koneksi: $e";
//     }
//   }
} // <--- Kurung tutup class AuthProvider
