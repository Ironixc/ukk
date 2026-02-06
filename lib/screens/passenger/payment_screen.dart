import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../constants.dart';
import 'home_screen.dart'; // Pastikan import Home Screen benar

class PaymentScreen extends StatefulWidget {
  final int idPembelian;
  final int totalHarga;

  PaymentScreen({required this.idPembelian, required this.totalHarga});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = "Transfer Bank BCA"; 
  bool _isProcessing = false; 

  final List<Map<String, dynamic>> _methods = [
    {'name': 'Transfer Bank BCA', 'icon': Icons.account_balance, 'color': Colors.blue},
    {'name': 'Transfer Bank Mandiri', 'icon': Icons.account_balance, 'color': Colors.blue[900]},
    {'name': 'GoPay', 'icon': Icons.account_balance_wallet, 'color': Colors.green},
    {'name': 'OVO', 'icon': Icons.monetization_on, 'color': Colors.purple},
    {'name': 'Indomaret / Alfamart', 'icon': Icons.store, 'color': Colors.red},
  ];

  void _payNow() async {
    setState(() => _isProcessing = true);
    await Future.delayed(Duration(seconds: 2)); // Delay palsu

    bool success = await Provider.of<BookingProvider>(context, listen: false)
        .processPayment(widget.idPembelian, _selectedMethod);

    setState(() => _isProcessing = false);

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pembayaran Gagal, coba lagi.")));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text("Pembayaran Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Tiket Anda sudah terbit dan berstatus LUNAS."),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                // PINDAH KE HOME TAB 1 (TIKET/HISTORY)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => PassengerHomeScreen(initialIndex: 1)),
                  (route) => false,
                );
              },
              child: Text("LIHAT TIKET SAYA"),
            )
          ],
        ),
      )
    );
  }

  void _payLater() {
    // LANGSUNG KE HISTORY (Status masih pending)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => PassengerHomeScreen(initialIndex: 1)),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Disimpan di Riwayat. Silakan bayar nanti."))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pembayaran"), backgroundColor: kPrimaryColor),
      body: _isProcessing 
        ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Memproses Pembayaran..."),
            ],
          ))
        : Column(
            children: [
              // HEADER TOTAL
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                color: Colors.grey[100],
                child: Column(
                  children: [
                    Text("Total Pembayaran", style: TextStyle(color: Colors.grey)),
                    Text("Rp ${widget.totalHarga}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kSecondaryColor)),
                    SizedBox(height: 5),
                    Text("ID Order: ${widget.idPembelian}", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Align(alignment: Alignment.centerLeft, child: Text("Pilih Metode Pembayaran:", style: TextStyle(fontWeight: FontWeight.bold))),
              ),

              // LIST METODE
              Expanded(
                child: ListView.builder(
                  itemCount: _methods.length,
                  itemBuilder: (ctx, i) {
                    final item = _methods[i];
                    bool isSelected = _selectedMethod == item['name'];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: isSelected ? kPrimaryColor : Colors.transparent, width: 2),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: ListTile(
                        leading: Icon(item['icon'], color: item['color']),
                        title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: isSelected ? Icon(Icons.check_circle, color: kPrimaryColor) : Icon(Icons.circle_outlined, color: Colors.grey),
                        onTap: () => setState(() => _selectedMethod = item['name']),
                      ),
                    );
                  },
                ),
              ),

              // TOMBOL AKSI
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,-5))]),
                child: Column(
                  children: [
                    SizedBox(width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
                        onPressed: _payNow,
                        child: Text("BAYAR SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(width: double.infinity, height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: kPrimaryColor, side: BorderSide(color: kPrimaryColor)),
                        onPressed: _payLater,
                        child: Text("BAYAR NANTI"),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
    );
  }
}