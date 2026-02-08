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
  String _stasiunAsal = "Gambir";
  String _stasiunTujuan = "Yogyakarta";
  DateTime _tanggalBerangkat = DateTime.now();
  int _passengerCount = 1; 
  
  int _selectedIndex = 0;

  final List<String> stations = [
    "Gambir", 
    "Bandung", 
    "Surabaya Gubeng", 
    "Malang", 
    "Yogyakarta", 
    "Solo Balapan", 
    "Semarang Tawang"
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime maxDate = now.add(Duration(days: 6)); 

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalBerangkat,
      firstDate: now, 
      lastDate: maxDate, 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: kPrimaryColor),
          ),
          child: child!,
        );
      }
    );
    if (picked != null) setState(() => _tanggalBerangkat = picked);
  }

  void _showStationPicker(bool isAsal) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Pilih Stasiun ${isAsal ? 'Asal' : 'Tujuan'}", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: stations.length,
                itemBuilder: (ctx, i) {
                  String currentStation = stations[i];
                  
                  // PERBAIKAN: Disable stasiun yang sedang dipilih di sisi lain
                  bool isDisabled = isAsal 
                    ? currentStation == _stasiunTujuan 
                    : currentStation == _stasiunAsal;
                  
                  return ListTile(
                    leading: Icon(
                      Icons.train, 
                      color: isDisabled ? Colors.grey : kPrimaryColor
                    ),
                    title: Text(
                      currentStation,
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : Colors.black
                      ),
                    ),
                    enabled: !isDisabled,
                    onTap: isDisabled ? null : () {
                      setState(() {
                        if (isAsal) {
                          _stasiunAsal = currentStation;
                        } else {
                          _stasiunTujuan = currentStation;
                        }
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPassengerSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder( 
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              height: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Jumlah Penumpang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Dewasa", style: TextStyle(fontSize: 16)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: kPrimaryColor),
                              onPressed: () {
                                if (_passengerCount > 1) {
                                  setModalState(() => _passengerCount--);
                                  setState(() {}); 
                                }
                              },
                            ),
                            Text("$_passengerCount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add, color: kPrimaryColor),
                              onPressed: () {
                                if (_passengerCount < 4) { 
                                  setModalState(() => _passengerCount++);
                                  setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Maksimal 4 penumpang per transaksi"))
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
                      onPressed: () => Navigator.pop(context),
                      child: Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

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
      backgroundColor: Colors.grey[100],
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
      case 0: return _buildHomeContent();
      case 1: return HistoryScreen();
      case 2: return AccountScreen();
      default: return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 280,
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
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
                            Text(
                              "KAI ACCESS", 
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 22, 
                                fontWeight: FontWeight.bold, 
                                letterSpacing: 1
                              )
                            ),
                            Text(
                              "For Your Easy Access", 
                              style: TextStyle(color: Colors.white70, fontSize: 12)
                            ),
                          ],
                        ),
                        Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(20, 130, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: kSecondaryColor, width: 3))
                            ),
                            child: Center(
                              child: Text(
                                "Intercity Trains", 
                                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)
                              )
                            ),
                          )
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Center(
                              child: Text("Local Trains", style: TextStyle(color: Colors.grey))
                            ),
                          )
                        ),
                      ],
                    ),
                    
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showStationPicker(true),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Origin", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      SizedBox(height: 5),
                                      Text(
                                        _stasiunAsal, 
                                        style: TextStyle(
                                          color: kPrimaryColor, 
                                          fontSize: 16, 
                                          fontWeight: FontWeight.bold
                                        ), 
                                        overflow: TextOverflow.ellipsis
                                      ),
                                      Text(
                                        "Stasiun $_stasiunAsal", 
                                        style: TextStyle(color: Colors.grey, fontSize: 10)
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _swapStations,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, 
                                    color: Colors.blue[50]
                                  ),
                                  child: Icon(Icons.swap_horiz, color: kPrimaryColor),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showStationPicker(false),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Destination", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      SizedBox(height: 5),
                                      Text(
                                        _stasiunTujuan, 
                                        style: TextStyle(
                                          color: kPrimaryColor, 
                                          fontSize: 16, 
                                          fontWeight: FontWeight.bold
                                        ), 
                                        overflow: TextOverflow.ellipsis
                                      ),
                                      Text(
                                        "Stasiun $_stasiunTujuan", 
                                        style: TextStyle(color: Colors.grey, fontSize: 10)
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15),
                          Divider(),
                          SizedBox(height: 15),

                          Row(
                            children: [
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
                              
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: _showPassengerSelector, 
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
                                          Text("$_passengerCount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSecondaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 5,
                              ),
                              onPressed: () {
                                // Validasi stasiun sama
                                if (_stasiunAsal == _stasiunTujuan) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Asal dan Tujuan tidak boleh sama!"))
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (_) => SearchScheduleScreen(
                                      asal: _stasiunAsal,
                                      tujuan: _stasiunTujuan,
                                      tanggal: DateFormat('yyyy-MM-dd').format(_tanggalBerangkat),
                                      passengerCount: _passengerCount, 
                                    )
                                  )
                                );
                              },
                              child: Text(
                                "SEARCH", 
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16
                                )
                              ),
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
        Text(
          label, 
          style: TextStyle(fontSize: 10, color: Colors.grey[700]), 
          textAlign: TextAlign.center
        ),
      ],
    );
  }
}