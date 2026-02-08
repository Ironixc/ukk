import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class BookingProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ==========================================================
  // 1. BAGIAN PENCARIAN JADWAL (DENGAN FILTER FRONTEND)
  // ==========================================================
  List<dynamic> _jadwal = []; 
  List<dynamic> get jadwal => _jadwal;

  // Fungsi pencarian dengan filter di frontend
  Future<void> getJadwal(String asal, String tujuan, String tanggal) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get all schedules from backend
      final url = Uri.parse('$baseUrl/jadwal.php');
      
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        List<dynamic> allData = data['data'];
        
        // Filter on frontend to match origin, destination, and date
        _jadwal = allData.where((item) {
          // Match origin (case insensitive)
          bool matchAsal = item['asal_keberangkatan'].toString().toLowerCase() == asal.toLowerCase();
          
          // Match destination (case insensitive)
          bool matchTujuan = item['tujuan_keberangkatan'].toString().toLowerCase() == tujuan.toLowerCase();
          
          // Match date (compare only date part, ignore time)
          bool matchTanggal = true;
          if (item['tanggal_berangkat'] != null && tanggal.isNotEmpty) {
            try {
              DateTime jadwalDate = DateTime.parse(item['tanggal_berangkat']);
              DateTime searchDate = DateTime.parse(tanggal);
              matchTanggal = jadwalDate.year == searchDate.year && 
                            jadwalDate.month == searchDate.month && 
                            jadwalDate.day == searchDate.day;
            } catch (e) {
              print("Date parse error: $e");
              matchTanggal = false;
            }
          }
          
          return matchAsal && matchTujuan && matchTanggal;
        }).toList();
        
        print("Found ${_jadwal.length} matching schedules for $asal -> $tujuan on $tanggal");
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
        headers: {'Content-Type': 'application/json'},
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