import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../constants.dart';

class BookingScreen extends StatefulWidget {
  final Map jadwal; // Data dari Search Screen

  BookingScreen({required this.jadwal});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();

  // Data List untuk Dropdown
  List<dynamic> _listGerbong = [];
  List<dynamic> _listKursi = [];
  
  // Pilihan User
  String? _selectedGerbong;
  String? _selectedKursi;

  @override
  void initState() {
    super.initState();
    // LOAD GERBONG OTOMATIS SAAT HALAMAN DIBUKA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGerbong();
    });
  }

  void _loadGerbong() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    // Ambil ID Kereta dari data jadwal yang dikirim
    String idKereta = widget.jadwal['id_kereta'].toString();
    
    // Panggil API
    List<dynamic> hasil = await provider.getGerbong(idKereta);
    
    setState(() {
      _listGerbong = hasil;
    });
  }

void _onGerbongChanged(String? val) async {
    setState(() {
      _selectedGerbong = val;
      _selectedKursi = null; 
      _listKursi = [];       
    });

    if (val != null) {
      // Ambil ID Jadwal dari data widget
      String idJadwal = widget.jadwal['id'].toString();

      // Panggil Provider dengan ID Gerbong DAN ID Jadwal
      final provider = Provider.of<BookingProvider>(context, listen: false);
      
      // UPDATE DISINI: Tambahkan idJadwal
      List<dynamic> hasil = await provider.getKursi(val, idJadwal);
      
      setState(() {
        _listKursi = hasil;
      });

      // Feedback jika kursi penuh
      if (hasil.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Maaf, Gerbong ini sudah penuh!"))
        );
      }
    }
  }

  void _submitOrder() async {
    if (_nikController.text.isEmpty || _selectedKursi == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lengkapi semua data!")));
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final booking = Provider.of<BookingProvider>(context, listen: false);

    final result = await booking.orderTiket(
      idPelanggan: user!.idPelanggan!,
      idJadwal: widget.jadwal['id'],
      penumpang: [
        {
          'nik': _nikController.text,
          'nama': _namaController.text,
          'id_kursi': _selectedKursi,
        }
      ],
    );

    if (result['status'] == 'success') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Berhasil!"),
          content: Text("Tiket berhasil dipesan."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog
                Navigator.pop(context); // Booking
                Navigator.pop(context); // Search
              }, 
              child: Text("OK")
            )
          ],
        )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${result['message']}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Isi Data Penumpang"), backgroundColor: kPrimaryColor),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Kereta
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.jadwal['nama_kereta'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Kelas: ${widget.jadwal['kelas']}"),
                  SizedBox(height: 5),
                  Text("Harga: Rp ${widget.jadwal['harga']}", style: TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Input Form
            TextField(controller: _nikController, decoration: InputDecoration(labelText: "NIK", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: _namaController, decoration: InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder())),
            SizedBox(height: 20),

            // Dropdown Gerbong
            Text("Pilih Gerbong", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: _selectedGerbong,
              hint: Text(_listGerbong.isEmpty ? "Memuat Gerbong..." : "Pilih Gerbong"),
              isExpanded: true,
              items: _listGerbong.map((g) {
                return DropdownMenuItem(value: g['id'].toString(), child: Text(g['nama_gerbong']));
              }).toList(),
              onChanged: _onGerbongChanged,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),

            // Dropdown Kursi
            Text("Pilih Kursi", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: _selectedKursi,
              hint: Text(_selectedGerbong == null ? "Pilih Gerbong Dulu" : "Pilih Kursi"),
              isExpanded: true,
              items: _listKursi.map((k) {
                return DropdownMenuItem(value: k['id'].toString(), child: Text("No. ${k['no_kursi']}"));
              }).toList(),
              onChanged: (val) => setState(() => _selectedKursi = val),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 30),

            // Tombol Pesan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Consumer<BookingProvider>(
                builder: (context, booking, _) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
                    onPressed: booking.isLoading ? null : _submitOrder,
                    child: booking.isLoading 
                      ? CircularProgressIndicator(color: Colors.white) 
                      : Text("PESAN SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}