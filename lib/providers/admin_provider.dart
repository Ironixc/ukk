import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  
  // VARIABLE DATA
  List<dynamic> _listKereta = [];
  List<dynamic> _listJadwal = [];
  List<dynamic> _listGerbong = []; // Detail gerbong untuk edit kursi

  // GETTERS
  bool get isLoading => _isLoading;
  List<dynamic> get listKereta => _listKereta;
  List<dynamic> get listJadwal => _listJadwal;
  List<dynamic> get listGerbong => _listGerbong;

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

  // 1B. GET DETAIL GERBONG (Untuk edit kursi)
  Future<void> getGerbongDetail(String idKereta) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kereta.php?detail=gerbong&id=$idKereta')
      );
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listGerbong = data['data'];
      }
    } catch (e) {
      print("Error Get Gerbong Detail: $e");
      _listGerbong = [];
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
  Future<bool> updateKereta(String id, String nama, String deskripsi, String kelas, String jumlahGerbong, String kuota) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/kereta.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama_kereta': nama,
          'deskripsi': deskripsi,
          'kelas': kelas,
          'jumlah_gerbong': jumlahGerbong,
          'kuota': kuota,
        }),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await getKereta();
        return true;
      }
      return false;
    } catch (e) {
      print("Error Update Kereta: $e");
      return false;
    }
  }

  // 3B. UPDATE KURSI DI GERBONG (FITUR BARU)
  Future<bool> updateSeatsInGerbong(String idGerbong, int newKuota) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/kereta.php?action=update_seats'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_gerbong': idGerbong,
          'new_kuota': newKuota,
        }),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return true;
      }
      return false;
    } catch (e) {
      print("Error Update Seats: $e");
      return false;
    }
  }

  // 4. DELETE KERETA
  Future<String> deleteKereta(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/kereta.php?id=$id'));
      final data = json.decode(res.body);
      if (data['status'] == 'success') {
        _listKereta.removeWhere((element) => element['id'].toString() == id);
        notifyListeners();
        return "success";
      }
      return data['message'];
    } catch (e) { 
      return "Koneksi Error"; 
    }
  }

  // ===========================================================================
  // BAGIAN 2: MANAJEMEN JADWAL (CRUD)
  // ===========================================================================

  // 1. GET JADWAL (ADMIN VERSION - NO PARAMS)
  Future<void> getJadwal() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/jadwal.php'); 
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listJadwal = data['data']; 
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
      final res = await http.delete(Uri.parse('$baseUrl/jadwal.php?id=$id'));
      final data = json.decode(res.body);
      if (data['status'] == 'success') {
        _listJadwal.removeWhere((element) => element['id'].toString() == id);
        notifyListeners();
        return "success";
      }
      return data['message'];
    } catch (e) { 
      return "Koneksi Error"; 
    }
  }
}