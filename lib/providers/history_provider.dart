import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class HistoryProvider with ChangeNotifier {
  List<dynamic> _riwayat = [];
  bool _isLoading = false;

  List<dynamic> get riwayat => _riwayat;
  bool get isLoading => _isLoading;

  Future<void> getHistory(int idPelanggan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/history.php?id_pelanggan=$idPelanggan');
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _riwayat = data['data'];
      } else {
        _riwayat = [];
      }
    } catch (e) {
      print("Error History: $e");
      _riwayat = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}