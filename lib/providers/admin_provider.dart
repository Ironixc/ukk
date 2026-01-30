import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _listKereta = [];

  bool get isLoading => _isLoading;
  List<dynamic> get listKereta => _listKereta;

  // --------------------------------------------------------
  // 1. FETCH DATA (GET)
  // --------------------------------------------------------
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

// ... imports ...

  // 1. FETCH DATA (Sudah OK, tidak perlu ubah)

  // 2. TAMBAH DATA (POST) - UPDATE PARAMETER
  Future<bool> addKereta(String nama, String deskripsi, String kelas, String jumlahGerbong, String kuota) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kereta.php'),
        body: {
          'nama_kereta': nama,
          'deskripsi': deskripsi,
          'kelas': kelas,
          'jumlah_gerbong': jumlahGerbong, // Parameter Baru
          'kuota': kuota, // Parameter Baru
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

  // 3. EDIT DATA (PUT) - UPDATE PARAMETER
  Future<bool> updateKereta(String id, String nama, String deskripsi, String kelas, String jumlahGerbong) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/kereta.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama_kereta': nama,
          'deskripsi': deskripsi,
          'kelas': kelas,
          'jumlah_gerbong': jumlahGerbong, // Parameter Baru (Target Jumlah)
        }),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await getKereta();
        return true;
      }
      return false;
    } catch (e) {
      print("Error Update: $e");
      return false;
    }
  }

  // --------------------------------------------------------
  // 4. HAPUS DATA (DELETE)
  // --------------------------------------------------------
  Future<String> deleteKereta(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/kereta.php?id=$id'));
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listKereta.removeWhere((item) => item['id'] == id); // Hapus dari UI langsung biar cepat
        notifyListeners();
        return "success";
      } else {
        return data['message']; // Kembalikan pesan error (misal: Foreign Key constraint)
      }
    } catch (e) {
      return "Terjadi kesalahan koneksi";
    }
  }

  // ... (kode kereta sebelumnya) ...

  List<dynamic> _listJadwal = [];
  List<dynamic> get listJadwal => _listJadwal;

  // 1. GET JADWAL
  Future<void> getJadwal() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/jadwal.php'));
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        _listJadwal = data['data'];
      }
    } catch (e) {
      print("Error Get Jadwal: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // 2. ADD JADWAL
  Future<bool> addJadwal(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jadwal.php'),
        body: body, // Kita kirim map langsung biar ringkas
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await getJadwal();
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
        await getJadwal();
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
        _listJadwal.removeWhere((item) => item['id'] == id);
        notifyListeners();
        return "success";
      }
      return data['message'];
    } catch (e) {
      return "Error Koneksi";
    }
  }
}