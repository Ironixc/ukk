import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../constants.dart';
import 'booking_screen.dart';

class SearchScheduleScreen extends StatefulWidget {
  final String asal;
  final String tujuan;
  final String tanggal; 
  final int passengerCount; // <-- TERIMA DATA DISINI

  SearchScheduleScreen({
    required this.asal,
    required this.tujuan,
    required this.tanggal,
    required this.passengerCount, // Wajib diisi
  });

  @override
  _SearchScheduleScreenState createState() => _SearchScheduleScreenState();
}

class _SearchScheduleScreenState extends State<SearchScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.parse(widget.tanggal);
    _fetchSchedules();
  }

  void _fetchSchedules() async {
    setState(() => _isLoading = true);
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final provider = Provider.of<BookingProvider>(context, listen: false);
    await provider.getJadwal(widget.asal, widget.tujuan, dateStr);
    setState(() {
      _schedules = provider.jadwal; 
      _isLoading = false;
    });
  }

  String _calculateDuration(String start, String end) {
    try {
      DateTime t1 = DateTime.parse(start);
      DateTime t2 = DateTime.parse(end);
      Duration diff = t2.difference(t1);
      return "${diff.inHours}j ${diff.inMinutes % 60}m";
    } catch (e) {
      return "-";
    }
  }

  String _getStationCode(String stationName) {
    if (stationName.length < 3) return stationName.toUpperCase();
    return stationName.substring(0, 3).toUpperCase();
  }

  String _formatTime(String dateTimeStr) {
    try {
      DateTime dt = DateTime.parse(dateTimeStr);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return "--:--";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.asal} ➝ ${widget.tujuan}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              "${DateFormat('EEE, d MMM yyyy').format(_selectedDate)} | ${widget.passengerCount} Penumpang", // TAMPILKAN DISINI
              style: TextStyle(fontSize: 12, color: Colors.white70)
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // KALENDER GESER
          Container(
            height: 80,
            color: kPrimaryColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7, 
              itemBuilder: (ctx, i) {
                DateTime date = DateTime.now().add(Duration(days: i )); 
                bool isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _fetchSchedules();
                  },
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    decoration: BoxDecoration(color: isSelected ? kSecondaryColor : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('E').format(date), style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(DateFormat('d').format(date), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator())
              : _schedules.isEmpty 
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.train_outlined, size: 80, color: Colors.grey), Text("Tidak ada jadwal tersedia.", style: TextStyle(color: Colors.grey))]))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: _schedules.length,
                    itemBuilder: (ctx, i) => _buildKaiStyleCard(_schedules[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKaiStyleCard(Map item) {
    String jamBerangkat = _formatTime(item['tanggal_berangkat']);
    String jamTiba = _formatTime(item['tanggal_kedatangan']);
    String durasi = _calculateDuration(item['tanggal_berangkat'], item['tanggal_kedatangan']);
    String kodeAsal = _getStationCode(item['asal_keberangkatan'] ?? widget.asal);
    String kodeTujuan = _getStationCode(item['tujuan_keberangkatan'] ?? widget.tujuan);

    DateTime jadwalDate = DateTime.parse(item['tanggal_berangkat']);
    bool isSameDay = jadwalDate.year == _selectedDate.year && jadwalDate.month == _selectedDate.month && jadwalDate.day == _selectedDate.day;
    
    if (!isSameDay) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => BookingScreen(
              jadwal: item,
              passengerCount: widget.passengerCount // <-- TERUSKAN DATA KE BOOKING SCREEN
            )
          ));
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['nama_kereta'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${item['kelas']} (Subclass H)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                  Text("Rp ${item['harga']}", style: TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(jamBerangkat, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(kodeAsal, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))]),
                  Expanded(child: Column(children: [Icon(Icons.arrow_forward, color: Colors.grey[300]), Text(durasi, style: TextStyle(fontSize: 11, color: Colors.grey))])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(jamTiba, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(kodeTujuan, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))]),
                ],
              ),
              SizedBox(height: 15),
              Divider(height: 1),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Tersedia", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
              ])
            ],
          ),
        ),
      ),
    );
  }
}