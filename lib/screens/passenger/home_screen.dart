import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../constants.dart';
import 'search_schedule_screen.dart'; 

class PassengerHomeScreen extends StatefulWidget {
  @override
  _PassengerHomeScreenState createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  String _stasiunAsal = "Pilih Stasiun...";
  String _stasiunTujuan = "Pilih Stasiun...";
  DateTime _tanggalBerangkat = DateTime.now();
  int _selectedIndex = 0;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalBerangkat,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _tanggalBerangkat = picked);
  }

  void _showStationPicker(bool isAsal) {
    // List Stasiun Dummy (Bisa diganti API Stasiun jika ada)
    final stations = ["Gambir", "Bandung", "Surabaya Gubeng", "Malang", "Yogyakarta", "Solo Balapan"];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        itemCount: stations.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(stations[i]),
          onTap: () {
            setState(() {
              isAsal ? _stasiunAsal = stations[i] : _stasiunTujuan = stations[i];
            });
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "Tiket"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Halo, Penumpang,", style: TextStyle(color: Colors.white70)),
                          Text("Mau kemana hari ini?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.notifications, color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 140, left: 20, right: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      _buildInput(Icons.train, "Asal", _stasiunAsal, () => _showStationPicker(true)),
                      Divider(),
                      _buildInput(Icons.location_on, "Tujuan", _stasiunTujuan, () => _showStationPicker(false)),
                      Divider(),
                      _buildInput(Icons.calendar_today, "Tanggal", DateFormat('dd MMM yyyy').format(_tanggalBerangkat), _pickDate),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
                          onPressed: () {
                            if (_stasiunAsal.contains("Pilih") || _stasiunTujuan.contains("Pilih")) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pilih stasiun dulu!")));
                              return;
                            }
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => SearchScheduleScreen(
                                asal: _stasiunAsal,
                                tujuan: _stasiunTujuan,
                                tanggal: DateFormat('yyyy-MM-dd').format(_tanggalBerangkat),
                              )
                            ));
                          },
                          child: Text("CARI TIKET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            )
          ],
        ),
      ),
    );
  }
}