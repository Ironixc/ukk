import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  
  // VARIABLE DATA
  List<dynamic> _listKereta = [];
  List<dynamic> _listJadwal = []; // Ganti nama biar konsisten

  // GETTERS
  bool get isLoading => _isLoading;
  List<dynamic> get listKereta => _listKereta;
  List<dynamic> get listJadwal => _listJadwal;

  // ===========================================================================
  // BAGIAN 1: MANAJEMEN KERETA (CRUD)
  // ===========================================================================
  
  // 1. GET KERETA
  Future<void> getKereta() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$baseUrl/kereta.php'));
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listKereta = data['data'];
      }
    } catch (e) {
      print("Error Get Kereta: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. ADD KERETA
  Future<bool> addKereta(String nama, String deskripsi, String kelas, String jumlahGerbong, String kuota) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kereta.php'),
        body: {
          'nama_kereta': nama,
          'deskripsi': deskripsi,
          'kelas': kelas,
          'jumlah_gerbong': jumlahGerbong,
          'kuota': kuota,
        },
      );
      
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await getKereta(); 
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 3. UPDATE KERETA
  Future<bool> updateKereta(String id, String nama, String deskripsi, String kelas, String jumlahGerbong) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/kereta.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama_kereta': nama,
          'deskripsi': deskripsi,
          'kelas': kelas,
          'jumlah_gerbong': jumlahGerbong,
        }),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await getKereta();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 4. DELETE KERETA
  Future<String> deleteKereta(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/kereta.php?id=$id'));
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listKereta.removeWhere((item) => item['id'] == id);
        notifyListeners();
        return "success";
      } else {
        return data['message'];
      }
    } catch (e) {
      return "Terjadi kesalahan koneksi";
    }
  }


  // ===========================================================================
  // BAGIAN 2: MANAJEMEN JADWAL (CRUD)
  // ===========================================================================

  // 1. GET JADWAL (ADMIN VERSION - NO PARAMS)
  // Admin mengambil SEMUA jadwal, tidak perlu parameter filter seperti user
  Future<void> getJadwal() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Panggil URL tanpa parameter search agar PHP mengembalikan semua data
      final url = Uri.parse('$baseUrl/jadwal.php'); 
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listJadwal = data['data']; // Simpan ke variable _listJadwal
      } else {
        _listJadwal = [];
      }
    } catch (e) {
      print("Error Get Jadwal Admin: $e");
      _listJadwal = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. ADD JADWAL
  Future<bool> addJadwal(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jadwal.php'),
        body: body, 
      );
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        await getJadwal(); // Refresh list (sekarang valid karena tanpa param)
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 3. UPDATE JADWAL
  Future<bool> updateJadwal(String id, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/jadwal.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        await getJadwal(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 4. DELETE JADWAL
  Future<String> deleteJadwal(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/jadwal.php?id=$id'));
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        _listJadwal.removeWhere((item) => item['id'] == id); // Variable sudah benar
        notifyListeners();
        return "success";
      }
      return data['message'];
    } catch (e) {
      return "Error Koneksi";
    }
  }
}