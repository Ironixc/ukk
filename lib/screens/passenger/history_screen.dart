import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/history_provider.dart';
import '../../constants.dart';
import 'ticket_detail_screen.dart';
import 'payment_screen.dart'; 

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
      backgroundColor: Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text("Tiket Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
        backgroundColor: kPrimaryColor, 
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          
          if (provider.riwayat.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.airplane_ticket_outlined, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 10),
                  Text("Belum ada riwayat tiket.", style: TextStyle(color: Colors.grey)),
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
              padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: provider.riwayat.length,
              itemBuilder: (context, index) {
                return _buildKaiCard(provider.riwayat[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildKaiCard(Map item) {
    // 1. Parsing Data Tanggal dengan Safety Check
    DateTime tglBerangkat;
    DateTime tglTiba;
    
    try {
      tglBerangkat = DateTime.parse(item['tanggal_berangkat']);
      tglTiba = DateTime.parse(item['tanggal_kedatangan']);
    } catch (e) {
      // Fallback jika data tanggal di database rusak/0000-00-00
      tglBerangkat = DateTime.now();
      tglTiba = DateTime.now();
    }
    
    String hariTanggal = DateFormat('EEE, d MMM yyyy').format(tglBerangkat);
    String jamBerangkat = DateFormat('HH:mm').format(tglBerangkat);
    String jamTiba = DateFormat('HH:mm').format(tglTiba);
    
    // Hitung durasi (Logic Fix: Cegah minus)
    Duration diff = tglTiba.difference(tglBerangkat);
    String durasi = "";
    if (diff.isNegative || diff.inDays > 1000) { 
      durasi = "-"; // Data error
    } else {
      durasi = "${diff.inHours}j ${diff.inMinutes % 60}m";
    }

    String status = item['status_pembayaran'] ?? 'pending';
    bool isLunas = status == 'lunas';
    int jumlahPenumpang = item['detail_penumpang'] != null ? item['detail_penumpang'].length : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 4))
        ]
      ),
      child: InkWell(
        onTap: () {
          if (isLunas) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailScreen(data: item)));
          } else {
             _goToPayment(item);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // ==========================================
            // HEADER: Nama Kereta & Kode Booking
            // ==========================================
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[100]!))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.train, color: kPrimaryColor, size: 20),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['nama_kereta'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(item['kelas'], style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Kode Booking", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(item['id_pembelian'].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor, fontSize: 16)),
                    ],
                  )
                ],
              ),
            ),

            // ==========================================
            // BODY: Timeline & Status
            // ==========================================
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Status & Tanggal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hariTanggal, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500)),
                      _buildStatusBadge(isLunas),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align Top
                    children: [
                      // KOLOM 1: JAM
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(jamBerangkat, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 28),
                          Text(jamTiba, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      
                      SizedBox(width: 15),

                      // KOLOM 2: GRAFIS GARIS
                      Column(
                        children: [
                          SizedBox(height: 4),
                          Icon(Icons.circle, size: 12, color: kSecondaryColor),
                          Container(
                            width: 2, 
                            height: 35,
                            color: Colors.grey[300],
                          ),
                          Icon(Icons.circle, size: 12, color: kPrimaryColor),
                        ],
                      ),

                      SizedBox(width: 15),

                      // KOLOM 3: STASIUN & DURASI
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['asal_keberangkatan'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            
                            // Durasi (Ditengah-tengah)
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Text(durasi, style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ),

                            Text(item['tujuan_keberangkatan'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            // ==========================================
            // FOOTER: Penumpang & Tombol
            // ==========================================
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isLunas ? Colors.grey[50] : Colors.orange[50], // Warna footer beda kalau belum bayar
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PENUMPANG (Kiri)
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 5),
                      Text(
                        "$jumlahPenumpang Penumpang",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700])
                      ),
                    ],
                  ),

                  // TOMBOL (Kanan)
                  isLunas
                  ? Row(
                      children: [
                        Text("Lihat Tiket", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        Icon(Icons.chevron_right, size: 16, color: kPrimaryColor)
                      ],
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: kSecondaryColor, borderRadius: BorderRadius.circular(20)),
                      child: Text("Bayar Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isLunas) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLunas ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(4)
      ),
      child: Text(
        isLunas ? "LUNAS" : "BELUM BAYAR",
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _goToPayment(Map item) {
    int id = int.parse(item['id_pembelian'].toString());
    int total = int.parse(item['total_harga'].toString());

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PaymentScreen(idPembelian: id, totalHarga: total)
    )).then((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if(user != null) Provider.of<HistoryProvider>(context, listen: false).getHistory(user.idPelanggan!);
    });
  }
}