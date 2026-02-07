import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import 'search_schedule_screen.dart';
import 'history_screen.dart';
import 'account_screen.dart';

class PassengerHomeScreen extends StatefulWidget {
  final int initialIndex;

  const PassengerHomeScreen({super.key, this.initialIndex = 0});

  @override
  _PassengerHomeScreenState createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  // DATA LOGIC (TETAP SAMA)
  String _stasiunAsal = "Gambir"; // Default value biar cantik
  String _stasiunTujuan = "Yogyakarta"; // Default value
  DateTime _tanggalBerangkat = DateTime.now();
  int _passengerCount = 1; // Visual saja
  
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // LOGIC DATE PICKER (TETAP SAMA)
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalBerangkat,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _tanggalBerangkat = picked);
  }

  // LOGIC STATION PICKER (TETAP SAMA)
  void _showStationPicker(bool isAsal) {
    final stations = ["Gambir", "Bandung", "Surabaya Gubeng", "Malang", "Yogyakarta", "Solo Balapan", "Semarang Tawang"];
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Pilih Stasiun ${isAsal ? 'Asal' : 'Tujuan'}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: stations.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: Icon(Icons.train, color: kPrimaryColor),
                  title: Text(stations[i]),
                  onTap: () {
                    setState(() {
                      isAsal ? _stasiunAsal = stations[i] : _stasiunTujuan = stations[i];
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LOGIC SWAP STATION (Tukar Asal & Tujuan)
  void _swapStations() {
    setState(() {
      String temp = _stasiunAsal;
      _stasiunAsal = _stasiunTujuan;
      _stasiunTujuan = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background abu muda
      
      // BOTTOM NAVIGATION (TETAP SAMA)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "My Ticket"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),

      body: _getSelectedPage(),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0: return _buildHomeContent(); // UI BARU ADA DISINI
      case 1: return HistoryScreen();
      case 2: return AccountScreen();
      default: return _buildHomeContent();
    }
  }

  // ===========================================================================
  // UI BERANDA BARU (MIRIP KAI ACCESS)
  // ===========================================================================
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              // 1. HEADER BIRU (BACKGROUND)
              Container(
                height: 280, // Lebih tinggi untuk menampung konten
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                decoration: BoxDecoration(
                  color: kPrimaryColor, // Warna Biru KAI
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("KAI ACCESS", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            Text("For Your Easy Access", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        Stack(
                          children: [
                            Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                            Positioned(right: 0, child: CircleAvatar(radius: 4, backgroundColor: Colors.red))
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // 2. KARTU PENCARIAN (FLOATING CARD)
              Container(
                margin: EdgeInsets.fromLTRB(20, 130, 20, 20), // Overlap ke header biru
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    // Tab Bar Palsu (Intercity vs Local)
                    Row(
                      children: [
                        Expanded(child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: kSecondaryColor, width: 3))
                          ),
                          child: Center(child: Text("Intercity Trains", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold))),
                        )),
                        Expanded(child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Center(child: Text("Local Trains", style: TextStyle(color: Colors.grey))),
                        )),
                      ],
                    ),
                    
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // ROW: ASAL <-> TUJUAN
                          Row(
                            children: [
                              // Asal
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showStationPicker(true),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Origin", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      SizedBox(height: 5),
                                      Text(_stasiunAsal, style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                      Text("Stasiun $_stasiunAsal", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Icon Swap
                              InkWell(
                                onTap: _swapStations,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[50]),
                                  child: Icon(Icons.swap_horiz, color: kPrimaryColor),
                                ),
                              ),
                              
                              // Tujuan
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showStationPicker(false),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Destination", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      SizedBox(height: 5),
                                      Text(_stasiunTujuan, style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                      Text("Stasiun $_stasiunTujuan", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15),
                          Divider(),
                          SizedBox(height: 15),

                          // ROW: TANGGAL & PENUMPANG
                          Row(
                            children: [
                              // Tanggal
                              Expanded(
                                flex: 3,
                                child: InkWell(
                                  onTap: _pickDate,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Departure Date", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16, color: kSecondaryColor),
                                          SizedBox(width: 8),
                                          Text(
                                            DateFormat('EEE, d MMM yyyy').format(_tanggalBerangkat), 
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Penumpang (Visual Saja)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Passenger", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.person, size: 16, color: kSecondaryColor),
                                        SizedBox(width: 5),
                                        Text("$_passengerCount Adult", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 25),

                          // TOMBOL SEARCH (ORANGE)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSecondaryColor, // Warna Orange
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 5,
                              ),
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
                              child: Text("SEARCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. MENU GRID (DUMMY MENUS DI BAWAH KARTU)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              children: [
                _buildMenuIcon(Icons.fastfood, "Pre-Order"),
                _buildMenuIcon(Icons.confirmation_number_outlined, "Check Booking"),
                _buildMenuIcon(Icons.cancel_outlined, "Cancellation"),
                _buildMenuIcon(Icons.edit_calendar, "Reschedule"),
                _buildMenuIcon(Icons.card_membership, "Membership"),
                _buildMenuIcon(Icons.map, "Map"),
                _buildMenuIcon(Icons.info_outline, "Info"),
                _buildMenuIcon(Icons.more_horiz, "More"),
              ],
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget Helper untuk Menu Icon
  Widget _buildMenuIcon(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!)
          ),
          child: Icon(icon, color: kPrimaryColor, size: 28),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700]), textAlign: TextAlign.center),
      ],
    );
  }
}