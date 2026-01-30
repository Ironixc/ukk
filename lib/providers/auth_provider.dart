import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user_model.dart'; // Import model yang baru dibuat

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
              namaPenumpang, // KUNCI: Harus 'nama_penumpang' sesuai PHP
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
          'username': identifier, // Pastikan ini 'username'
          'password': password,
        },
      );

      // 2. Cek Apa Balasan Server
      print("Status Code: ${response.statusCode}");
      print("Respon Server: ${response.body}"); // <--- INI PALING PENTING
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
      print("ERROR KONEKSI: $e"); // <--- Cek jika ada error internet
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

} // <--- Kurung tutup class AuthProvider