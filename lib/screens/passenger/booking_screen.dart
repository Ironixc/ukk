import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/seat_map_widget.dart'; // Import Widget Baru
import '../../constants.dart';

class BookingScreen extends StatefulWidget {
  final Map jadwal; // Data jadwal dari halaman sebelumnya

  BookingScreen({required this.jadwal});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // DATA FORM PENUMPANG
  List<Map<String, dynamic>> _passengers = [];

  // DATA UNTUK KURSI & GERBONG
  List<dynamic> _listGerbong = [];
  List<dynamic> _allSeatsInGerbong = []; // Semua Kursi (Untuk digambar)
  List<String> _occupiedSeatIds = [];    // Kursi Terisi (Warna Orange)
  List<String> _mySelectedSeatIds = [];  // Pilihan Saya (Warna Biru)
  
  String? _selectedGerbong;

  @override
  void initState() {
    super.initState();
    _initFirstPassenger(); // Auto isi user login
    
    // Load Gerbong setelah frame UI jadi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGerbong();
    });
  }

  // 1. INIT PENUMPANG PERTAMA (READ ONLY)
  void _initFirstPassenger() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _passengers.add({
      'nik': TextEditingController(text: user?.nik ?? ''),
      'nama': TextEditingController(text: user?.namaLengkap ?? ''),
      'kursi': null, // Nanti diisi dari Seat Map
      'is_user': true,
    });
  }

  // 2. TAMBAH / HAPUS PENUMPANG
  void _addPassenger() {
    setState(() {
      _passengers.add({
        'nik': TextEditingController(),
        'nama': TextEditingController(),
        'kursi': null,
        'is_user': false,
      });
      // Saat tambah orang, reset pilihan kursi agar milih ulang yg pas
      _mySelectedSeatIds = [];
      for (var p in _passengers) p['kursi'] = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Penumpang ditambah. Silakan pilih kursi lagi.")));
  }

  void _removePassenger(int index) {
    setState(() {
      _passengers.removeAt(index);
      _mySelectedSeatIds = []; // Reset pilihan kursi
       for (var p in _passengers) p['kursi'] = null;
    });
  }

  // 3. LOAD DATA API
  void _loadGerbong() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    String idKereta = widget.jadwal['id_kereta'].toString();
    List<dynamic> res = await provider.getGerbong(idKereta);
    setState(() => _listGerbong = res);
  }

  // LOGIKA UTAMA: FETCH KURSI & STATUSNYA
  void _onGerbongChanged(String? val) async {
    setState(() {
      _selectedGerbong = val;
      _mySelectedSeatIds = [];
      for (var p in _passengers) p['kursi'] = null;
      _allSeatsInGerbong = [];
    });

    if (val != null) {
      final provider = Provider.of<BookingProvider>(context, listen: false);
      String idJadwal = widget.jadwal['id'].toString();

      // STEP A: Ambil SEMUA kursi di gerbong ini (Tanpa Filter Jadwal)
      // Gunakan parameter idJadwal kosong '' agar PHP mengembalikan semua kursi
      List<dynamic> allSeats = await provider.getKursi(val, '');
      
      // STEP B: Ambil kursi yang TERSEDIA (Dengan Filter Jadwal)
      List<dynamic> availableSeats = await provider.getKursi(val, idJadwal);

      // STEP C: Bandingkan untuk mencari kursi TERISI (Occupied)
      Set<String> availIds = availableSeats.map((e) => e['id'].toString()).toSet();
      List<String> occupiedList = [];

      for (var s in allSeats) {
        String sId = s['id'].toString();
        if (!availIds.contains(sId)) {
          occupiedList.add(sId); // Jika tidak ada di available, berarti terisi
        }
      }

      setState(() {
        _allSeatsInGerbong = allSeats;
        _occupiedSeatIds = occupiedList;
      });
    }
  }

  // 4. BUKA MODAL SEAT MAP
  void _openSeatMap() {
    if (_selectedGerbong == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pilih Gerbong dulu!")));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Fullscreen style
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85, // 85% layar
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          padding: EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  Text("Pilih Kursi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Tap kursi untuk memilih (${_mySelectedSeatIds.length}/${_passengers.length})", 
                       style: TextStyle(color: Colors.grey)),
                  Divider(),
                  
                  // WIDGET DENAH KURSI
                  Expanded(
                    child: SeatMapWidget(
                      allSeats: _allSeatsInGerbong,
                      occupiedSeats: _occupiedSeatIds,
                      selectedSeats: _mySelectedSeatIds,
                      passengerCount: _passengers.length,
                      onSeatSelected: (newSelection) {
                        setModalState(() {
                          _mySelectedSeatIds = newSelection;
                        });
                      },
                    ),
                  ),

                  // TOMBOL SIMPAN
                  SizedBox(width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                      onPressed: () {
                        // VALIDASI JUMLAH
                        if (_mySelectedSeatIds.length != _passengers.length) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Anda harus memilih ${_passengers.length} kursi!")
                          ));
                          return;
                        }

                        // MAPPING KURSI KE PENUMPANG
                        // Kursi pertama untuk penumpang 1, dst.
                        setState(() {
                           for (int i = 0; i < _passengers.length; i++) {
                             _passengers[i]['kursi'] = _mySelectedSeatIds[i];
                           }
                        });
                        Navigator.pop(context); // Tutup Modal
                      },
                      child: Text("SIMPAN PILIHAN"),
                    ),
                  )
                ],
              );
            }
          ),
        );
      }
    );
  }

  // 5. SUBMIT KE DATABASE
  void _submitOrder() async {
    // Cek kelengkapan
    bool isIncomplete = _passengers.any((p) => 
      p['nik'].text.isEmpty || p['nama'].text.isEmpty || p['kursi'] == null
    );

    if (isIncomplete) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lengkapi data dan pilih kursi!")));
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final booking = Provider.of<BookingProvider>(context, listen: false);

    // Format Data
    List<Map<String, dynamic>> payload = _passengers.map((p) {
      return {
        'nik': p['nik'].text,
        'nama': p['nama'].text,
        'id_kursi': p['kursi'],
      };
    }).toList();

    final result = await booking.orderTiket(
      idPelanggan: user!.idPelanggan!,
      idJadwal: widget.jadwal['id'],
      penumpang: payload,
    );

    if (result['status'] == 'success') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text("Berhasil!"),
          content: Text("Tiket berhasil dipesan."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text("OK"),
            )
          ],
        )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${result['message']}")));
    }
  }

  // HELPER UNTUK DAPAT NOMOR KURSI DARI ID
  String _getSeatDisplay(String? id) {
    if (id == null) return "Belum dipilih";
    try {
      var seat = _allSeatsInGerbong.firstWhere((e) => e['id'].toString() == id);
      return "No. ${seat['no_kursi']}";
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pesan Tiket"), backgroundColor: kPrimaryColor),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO JADWAL
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Text("${widget.jadwal['nama_kereta']} (${widget.jadwal['kelas']})", style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("Berangkat: ${widget.jadwal['tanggal_berangkat']}"),
                    Text("Rp ${widget.jadwal['harga']}", style: TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor)),
                  ])
                ],
              ),
            ),
            SizedBox(height: 20),

            // PILIH GERBONG
            Text("1. Pilih Gerbong", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedGerbong,
              hint: Text("Pilih Gerbong..."),
              isExpanded: true,
              items: _listGerbong.map((g) => DropdownMenuItem(value: g['id'].toString(), child: Text(g['nama_gerbong']))).toList(),
              onChanged: _onGerbongChanged,
            ),
            SizedBox(height: 20),

            if (_selectedGerbong != null) ...[
              // LIST FORM PENUMPANG
              Text("2. Detail Penumpang & Kursi", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _passengers.length,
                separatorBuilder: (ctx, i) => SizedBox(height: 15),
                itemBuilder: (ctx, i) => _buildPassengerCard(i),
              ),

              // TOMBOL TAMBAH PENUMPANG
              SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  icon: Icon(Icons.person_add),
                  label: Text("Tambah Penumpang Lain"),
                  onPressed: _addPassenger,
                ),
              ),
              SizedBox(height: 20),

              // TOMBOL BUKA SEAT MAP
              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.grid_on),
                  label: Text("PILIH KURSI (DENAH)"),
                  style: OutlinedButton.styleFrom(foregroundColor: kPrimaryColor, side: BorderSide(color: kPrimaryColor)),
                  onPressed: _openSeatMap,
                ),
              ),
              SizedBox(height: 30),

              // TOMBOL BAYAR
              SizedBox(
                width: double.infinity, height: 50,
                child: Consumer<BookingProvider>(
                  builder: (ctx, booking, _) => ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
                    onPressed: booking.isLoading ? null : _submitOrder,
                    child: booking.isLoading ? CircularProgressIndicator(color: Colors.white) : Text("BAYAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerCard(int index) {
    var p = _passengers[index];
    bool isUser = p['is_user'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Penumpang ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
              if (!isUser) IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _removePassenger(index))
            ]),
            TextField(
              controller: p['nama'], readOnly: isUser,
              decoration: InputDecoration(labelText: "Nama", filled: isUser, fillColor: Colors.grey[100]),
            ),
            SizedBox(height: 8),
            TextField(
              controller: p['nik'], readOnly: isUser,
              decoration: InputDecoration(labelText: "NIK", filled: isUser, fillColor: Colors.grey[100]),
            ),
            SizedBox(height: 8),
            // DISPLAY KURSI (Bukan Dropdown)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(5)),
              child: Text(
                "Kursi: ${_getSeatDisplay(p['kursi'])}",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
            )
          ],
        ),
      ),
    );
  }
}