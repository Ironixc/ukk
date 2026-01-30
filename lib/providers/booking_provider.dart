import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class BookingProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 1. Ambil List Gerbong berdasarkan Kereta
  Future<List<dynamic>> getGerbong(String idKereta) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gerbong.php?id_kereta=$idKereta'));
      final data = json.decode(response.body);
      return data['status'] == 'success' ? data['data'] : [];
    } catch (e) {
      return [];
    }
  }

  // 2. Ambil List Kursi berdasarkan Gerbong
  Future<List<dynamic>> getKursi(String idGerbong) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kursi.php?id_gerbong=$idGerbong'));
      final data = json.decode(response.body);
      return data['status'] == 'success' ? data['data'] : [];
    } catch (e) {
      return [];
    }
  }

  // 3. PROSES BOOKING (Kirim JSON)
  Future<Map<String, dynamic>> orderTiket({
    required int idPelanggan,
    required String idJadwal,
    required List<Map<String, dynamic>> penumpang,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/booking.php');
      
      // Kirim sebagai RAW JSON
      final body = json.encode({
        'id_pelanggan': idPelanggan,
        'id_jadwal': idJadwal,
        'penumpang': penumpang
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      _isLoading = false;
      notifyListeners();
      return json.decode(response.body);

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'status': 'error', 'message': e.toString()};
    }
  }
}