import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';


class AdminReportProvider with ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _allTransactions = [];
  List<dynamic> _monthlyRecap = [];

  bool get isLoading => _isLoading;
  List<dynamic> get allTransactions => _allTransactions;
  List<dynamic> get monthlyRecap => _monthlyRecap;

  Future<void> getAllHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin_stats.php?action=history'));
      // DEBUG: Cek di console apakah data muncul?
      print("History Data Raw: ${response.body}"); 
      
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        _allTransactions = data['data'];
      }
    } catch (e) {
      print("Error History: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getMonthlyRecap() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin_stats.php?action=recap'));
      print("Recap Data Raw: ${response.body}");
      
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        _monthlyRecap = data['data'];
      }
    } catch (e) {
      print("Error Recap: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
  
}