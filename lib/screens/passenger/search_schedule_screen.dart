import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart'; // Kita pakai AdminProvider utk fetch jadwal
import '../../constants.dart';
import 'booking_screen.dart'; // Kita hubungkan ke file ke-3

class SearchScheduleScreen extends StatefulWidget {
  final String asal;
  final String tujuan;
  final String tanggal;

  SearchScheduleScreen({required this.asal, required this.tujuan, required this.tanggal});

  @override
  _SearchScheduleScreenState createState() => _SearchScheduleScreenState();
}

class _SearchScheduleScreenState extends State<SearchScheduleScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data jadwal dari server saat halaman dibuka
    Future.microtask(() => 
      Provider.of<AdminProvider>(context, listen: false).getJadwal()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.asal} ➝ ${widget.tujuan}"),
        backgroundColor: kPrimaryColor,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());

          // LOGIKA FILTER: Hanya tampilkan jadwal yang sesuai Asal & Tujuan
          final filteredList = provider.listJadwal.where((jadwal) {
            String dbAsal = jadwal['asal_keberangkatan'].toString().toLowerCase();
            String dbTujuan = jadwal['tujuan_keberangkatan'].toString().toLowerCase();
            return dbAsal.contains(widget.asal.toLowerCase()) && 
                   dbTujuan.contains(widget.tujuan.toLowerCase());
          }).toList();

          if (filteredList.isEmpty) {
            return Center(child: Text("Tidak ada jadwal kereta ditemukan."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () {
                    // NAVIGASI KE SCREEN 3 (BOOKING)
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BookingScreen(jadwal: item)
                    ));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['nama_kereta'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Rp ${item['harga']}", style: TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${item['asal_keberangkatan']}\n${item['tanggal_berangkat']}"),
                            Icon(Icons.arrow_forward, color: Colors.grey),
                            Text("${item['tujuan_keberangkatan']}\n${item['tanggal_kedatangan']}", textAlign: TextAlign.right),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}