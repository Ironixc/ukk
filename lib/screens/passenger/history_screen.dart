import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/history_provider.dart';
import '../../constants.dart';
import 'ticket_detail_screen.dart';
import 'payment_screen.dart'; // Import Payment untuk bayar utang

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<HistoryProvider>(context, listen: false).getHistory(user.idPelanggan!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Perjalanan"), backgroundColor: kPrimaryColor, automaticallyImplyLeading: false),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          
          if (provider.riwayat.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Belum ada riwayat transaksi.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
              await Provider.of<HistoryProvider>(context, listen: false).getHistory(user!.idPelanggan!);
            },
            child: ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: provider.riwayat.length,
              itemBuilder: (context, index) {
                final item = provider.riwayat[index];
                return _buildHistoryCard(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map item) {
    DateTime tgl = DateTime.parse(item['tanggal_berangkat']);
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(tgl);

    // Cek Status (Default pending jika null)
    String status = item['status_pembayaran'] ?? 'pending';
    bool isLunas = status == 'lunas';

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // Hanya bisa lihat detail jika LUNAS
          if (isLunas) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => TicketDetailScreen(data: item)
            ));
          } else {
             _goToPayment(item);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['nama_kereta'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  
                  // BADGE STATUS
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLunas ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(
                      isLunas ? "LUNAS" : "BELUM BAYAR", 
                      style: TextStyle(
                        color: isLunas ? Colors.green[800] : Colors.orange[900], 
                        fontSize: 10, fontWeight: FontWeight.bold
                      )
                    ),
                  )
                ],
              ),
              Text(item['kelas'], style: TextStyle(color: Colors.grey, fontSize: 12)),
              Divider(),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(formattedDate, style: TextStyle(fontSize: 13)),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.route, size: 14, color: Colors.grey),
                  SizedBox(width: 5),
                  Text("${item['asal_keberangkatan']} ➝ ${item['tujuan_keberangkatan']}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${item['detail_penumpang'].length} Penumpang", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  
                  // LOGIC TOMBOL KANAN BAWAH
                  isLunas 
                  ? Text("Rp ${item['total_harga']}", style: TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor, fontSize: 16))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        minimumSize: Size(0, 30)
                      ),
                      onPressed: () => _goToPayment(item),
                      child: Text("BAYAR SEKARANG", style: TextStyle(fontSize: 12)),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _goToPayment(Map item) {
    int id = int.parse(item['id_pembelian'].toString());
    int total = int.parse(item['total_harga'].toString());

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PaymentScreen(idPembelian: id, totalHarga: total)
    )).then((_) {
      // Refresh saat kembali
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if(user != null) Provider.of<HistoryProvider>(context, listen: false).getHistory(user.idPelanggan!);
    });
  }
}