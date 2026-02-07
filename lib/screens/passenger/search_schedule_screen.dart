import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../constants.dart';
import 'booking_screen.dart';

class SearchScheduleScreen extends StatefulWidget {
  final String asal;
  final String tujuan;
  final String tanggal; // Format awal: yyyy-MM-dd

  SearchScheduleScreen({
    required this.asal,
    required this.tujuan,
    required this.tanggal,
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
    // Parse tanggal dari parameter awal
    _selectedDate = DateTime.parse(widget.tanggal);
    // Langsung cari jadwal
    _fetchSchedules();
  }

  // Fungsi Cari Jadwal ke API
  void _fetchSchedules() async {
    setState(() => _isLoading = true);
    
    // Format tanggal ke string untuk API (yyyy-MM-dd)
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // Panggil Provider
    final provider = Provider.of<BookingProvider>(context, listen: false);
    
    // Pastikan fungsi getJadwal di Provider mendukung filter tanggal!
    // Jika API Anda belum support filter tanggal, dia akan menampilkan semua jadwal (tetap aman).
    await provider.getJadwal(widget.asal, widget.tujuan, dateStr);
    
    setState(() {
      _schedules = provider.jadwal; // Ambil data dari provider
      _isLoading = false;
    });
  }

  // Fungsi Hitung Durasi (Selisih Waktu)
  String _calculateDuration(String start, String end) {
    try {
      // API biasanya kirim format "2024-02-05 08:00:00"
      // Kita perlu parsing jam-nya saja atau full datetime
      DateTime t1 = DateTime.parse(start);
      DateTime t2 = DateTime.parse(end);
      Duration diff = t2.difference(t1);
      
      int hours = diff.inHours;
      int minutes = diff.inMinutes % 60;
      return "${hours}j ${minutes}m";
    } catch (e) {
      return "-";
    }
  }

  // Fungsi Generate Kode Stasiun (Dummy)
  // Misal: Gambir -> GMR, Surabaya -> SBY
  String _getStationCode(String stationName) {
    if (stationName.length < 3) return stationName.toUpperCase();
    // Logika sederhana: Ambil huruf kapital / 3 huruf pertama
    return stationName.substring(0, 3).toUpperCase();
  }

  // Fungsi Ambil Jam Saja (HH:mm)
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.asal} ➝ ${widget.tujuan}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              "${DateFormat('EEE, d MMM yyyy').format(_selectedDate)} | 1 Penumpang", 
              style: TextStyle(fontSize: 12, color: Colors.white70)
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. DATE STRIP (KALENDER GESER ala KAI ACCESS)
          Container(
            height: 80,
            color: kPrimaryColor, // Background biru nyambung sama AppBar
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14, // Tampilkan 2 minggu ke depan
              itemBuilder: (ctx, i) {
                // Generate tanggal mulai dari H-3 sampai H+10 biar user bisa liat tanggal kemarin dikit
                DateTime date = DateTime.now().add(Duration(days: i - 2)); 
                bool isSelected = 
                    date.day == _selectedDate.day && 
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    _fetchSchedules(); // Refresh data saat tanggal ganti
                  },
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? kSecondaryColor : Colors.transparent, // Orange kalau dipilih
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date), // Nama Hari (Mon, Tue)
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold
                          )
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('d').format(date), // Tanggal Angka (05)
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          )
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. LIST JADWAL
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator())
              : _schedules.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.train_outlined, size: 80, color: Colors.grey),
                        Text("Tidak ada jadwal tersedia.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: _schedules.length,
                    itemBuilder: (ctx, i) {
                      final item = _schedules[i];
                      return _buildKaiStyleCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // WIDGET KARTU JADWAL ALA KAI ACCESS
  Widget _buildKaiStyleCard(Map item) {
    String jamBerangkat = _formatTime(item['tanggal_berangkat']);
    String jamTiba = _formatTime(item['tanggal_kedatangan']);
    String durasi = _calculateDuration(item['tanggal_berangkat'], item['tanggal_kedatangan']);
    String kodeAsal = _getStationCode(item['asal_keberangkatan'] ?? widget.asal);
    String kodeTujuan = _getStationCode(item['tujuan_keberangkatan'] ?? widget.tujuan);

    // Filter manual di sisi UI (jika API mengembalikan semua tanggal)
    // Cek apakah tanggal jadwal == tanggal yang dipilih di kalender atas
    DateTime jadwalDate = DateTime.parse(item['tanggal_berangkat']);
    bool isSameDay = jadwalDate.year == _selectedDate.year &&
                     jadwalDate.month == _selectedDate.month &&
                     jadwalDate.day == _selectedDate.day;
    
    // Jika tanggal beda, jangan tampilkan (Return widget kosong)
    if (!isSameDay) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => BookingScreen(jadwal: item)
          ));
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // BARIS 1: Nama Kereta & Harga
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama_kereta'], 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                      Text(
                        "${item['kelas']} (Subclass H)", // Dummy subclass biar mirip
                        style: TextStyle(color: Colors.grey, fontSize: 12)
                      ),
                    ],
                  ),
                  Text(
                    "Rp ${item['harga']}", 
                    style: TextStyle(
                      color: kSecondaryColor, // Warna Orange Harga
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                ],
              ),
              SizedBox(height: 15),

              // BARIS 2: Jam & Rute (Inti Desain KAI)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BERANGKAT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jamBerangkat, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(kodeAsal, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  // TENGAH (Durasi & Panah)
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.grey[300]),
                        Text(durasi, style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),

                  // TIBA
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(jamTiba, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(kodeTujuan, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 15),
              Divider(height: 1),
              SizedBox(height: 10),

              // BARIS 3: Status Tersedia
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tersedia", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}