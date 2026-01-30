import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart'; // Pastikan file ini ada
import '../../constants.dart';

class BookingScreen extends StatefulWidget {
  final Map jadwal; // Data jadwal dilempar dari Search Screen

  BookingScreen({required this.jadwal});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();

  // Variabel Dropdown
  List<dynamic> _listGerbong = [];
  List<dynamic> _listKursi = [];
  String? _selectedGerbong;
  String? _selectedKursi;

  @override
  void initState() {
    super.initState();
    // Load Gerbong berdasarkan ID Kereta dari jadwal
    final provider = Provider.of<BookingProvider>(context, listen: false);
    provider.getGerbong(widget.jadwal['id_kereta']).then((value) {
      setState(() => _listGerbong = value);
    });
  }

  // Saat Gerbong dipilih, Load Kursi
  void _onGerbongChanged(String? val) {
    setState(() {
      _selectedGerbong = val;
      _selectedKursi = null; // Reset kursi
      _listKursi = [];
    });
    if (val != null) {
      Provider.of<BookingProvider>(context, listen: false)
          .getKursi(val)
          .then((value) {
            setState(() => _listKursi = value);
      });
    }
  }

  // Fungsi Submit Order
  void _submitOrder() async {
    if (_nikController.text.isEmpty || _selectedKursi == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data belum lengkap!")));
      return;
    }

    // Kirim data ke Backend
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
                 Navigator.pop(context); // Tutup dialog
                 Navigator.pop(context); // Tutup booking screen
                 Navigator.pop(context); // Balik ke Home
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
              padding: EdgeInsets.all(15),
              color: Colors.blue[50],
              child: Text("Kereta: ${widget.jadwal['nama_kereta']} - ${widget.jadwal['kelas']}", 
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),

            // Form Input
            TextField(controller: _nikController, decoration: InputDecoration(labelText: "NIK", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: _namaController, decoration: InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder())),
            SizedBox(height: 20),

            // Dropdown Gerbong
            DropdownButtonFormField<String>(
              value: _selectedGerbong,
              hint: Text("Pilih Gerbong"),
              items: _listGerbong.map((g) {
                return DropdownMenuItem(value: g['id'].toString(), child: Text(g['nama_gerbong']));
              }).toList(),
              onChanged: _onGerbongChanged,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),

            // Dropdown Kursi
            DropdownButtonFormField<String>(
              value: _selectedKursi,
              hint: Text("Pilih Kursi"),
              items: _listKursi.map((k) {
                return DropdownMenuItem(value: k['id'].toString(), child: Text("No. ${k['no_kursi']}"));
              }).toList(),
              onChanged: (val) => setState(() => _selectedKursi = val),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 30),

            // Tombol Bayar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
                onPressed: _submitOrder,
                child: Text("PESAN SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}