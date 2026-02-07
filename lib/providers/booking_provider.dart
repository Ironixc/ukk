import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class BookingProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ==========================================================
  // 1. BAGIAN PENCARIAN JADWAL (YANG HILANG TADI)
  // ==========================================================
  List<dynamic> _jadwal = []; 
  List<dynamic> get jadwal => _jadwal; // <-- Ini Getter yang dicari oleh error 'undefined_getter'

  // Fungsi ini yang dicari oleh error 'undefined_method'
  Future<void> getJadwal(String asal, String tujuan, String tanggal) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/jadwal.php?asal=$asal&tujuan=$tujuan&tanggal=$tanggal');
      
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _jadwal = data['data'];
      } else {
        _jadwal = [];
      }
    } catch (e) {
      print("Error Get Jadwal: $e");
      _jadwal = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==========================================================
  // 2. BAGIAN GERBONG & KURSI (KODE LAMA ANDA)
  // ==========================================================
  
  // Ambil List Gerbong
  Future<List<dynamic>> getGerbong(String idKereta) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gerbong.php?id_kereta=$idKereta'));
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        return data['data']; 
      } else {
        return [];
      }
    } catch (e) {
      print("Error Get Gerbong: $e");
      return [];
    }
  }

  // Ambil List Kursi
  Future<List<dynamic>> getKursi(String idGerbong, String idJadwal) async {
    try {
      final url = Uri.parse('$baseUrl/kursi.php?id_gerbong=$idGerbong&id_jadwal=$idJadwal');
      final response = await http.get(url);
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        return data['data']; 
      } else {
        return [];
      }
    } catch (e) {
      print("Error Get Kursi: $e");
      return [];
    }
  }

  // ==========================================================
  // 3. BAGIAN TRANSAKSI (BOOKING & PAYMENT)
  // ==========================================================
  
  // Kirim Pesanan
  Future<Map<String, dynamic>> orderTiket({
    required int idPelanggan,
    required String idJadwal,
    required List<Map<String, dynamic>> penumpang,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/booking.php');
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

  // Proses Pembayaran
  Future<bool> processPayment(int idPembelian, String metode) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/payment.php');
      final response = await http.post(
        url,
        body: json.encode({
          'id_pembelian': idPembelian,
          'metode_pembayaran': metode,
        }),
      );

      final data = json.decode(response.body);
      _isLoading = false;
      notifyListeners();

      if (data['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Payment Error: $e");
      return false;
    }
  }
}