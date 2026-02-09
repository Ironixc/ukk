import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/seat_map_widget.dart';
import '../../constants.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Map jadwal; 
  final int passengerCount; //Jumlah Penumpang dari halaman Search

  // Default 1 jika tidak ada data lemparan
  BookingScreen({required this.jadwal, this.passengerCount = 1});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // DATA FORM PENUMPANG
  List<Map<String, dynamic>> _passengers = [];

  // DATA UNTUK KURSI & GERBONG
  List<dynamic> _listGerbong = [];
  List<dynamic> _allSeatsInGerbong = [];
  List<String> _occupiedSeatIds = [];
  List<String> _mySelectedSeatIds = [];
  
  String? _selectedGerbong;
  bool _isLoadingKursi = false;

  @override
  void initState() {
    super.initState();
    _initPassengers(); // Inisialisasi form sesuai jumlah penumpang
    
    // Load Gerbong setelah frame UI jadi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGerbong();
    });
  }

  // VALIDASI NIK
  String? _validateNIK(String? value, bool isMainUser) {
    if (isMainUser) return null; // User utama sudah tervalidasi saat register
    
    if (value == null || value.isEmpty) {
      return 'NIK wajib diisi';
    }
    // Hapus semua karakter non-digit
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length != 16) {
      return 'NIK harus tepat 16 digit';
    }
    return null;
  }

  // VALIDASI NAMA
  String? _validateNama(String? value, bool isMainUser) {
    if (isMainUser) return null; // User utama sudah tervalidasi saat register
    
    if (value == null || value.isEmpty) {
      return 'Nama wajib diisi';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    if (value.length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    // Hanya boleh huruf dan spasi
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Nama hanya boleh berisi huruf dan spasi';
    }
    return null;
  }

  // 1. GENERATE FORM SESUAI JUMLAH PENUMPANG
  void _initPassengers() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    for (int i = 0; i < widget.passengerCount; i++) {
      bool isMainUser = (i == 0); // Penumpang pertama otomatis diisi data akun login
      _passengers.add({
        'nik': TextEditingController(text: isMainUser ? (user?.nik ?? '') : ''),
        'nama': TextEditingController(text: isMainUser ? (user?.namaLengkap ?? '') : ''),
        'kursi': null, 
        'is_user': isMainUser,
        'nik_error': null,
        'nama_error': null,
      });
    }
  }

  // 2. LOAD GERBONG
  void _loadGerbong() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    String idKereta = widget.jadwal['id_kereta'].toString();
    List<dynamic> res = await provider.getGerbong(idKereta);
    setState(() => _listGerbong = res);
    
    // Otomatis pilih gerbong pertama jika ada
    if (res.isNotEmpty) {
      _onGerbongChanged(res[0]['id'].toString());
    }
  }

  // 3. FETCH KURSI SAAT GERBONG GANTI
  void _onGerbongChanged(String? val) async {
    setState(() {
      _selectedGerbong = val;
      _isLoadingKursi = true;
      _allSeatsInGerbong = [];
    });

    if (val != null) {
      final provider = Provider.of<BookingProvider>(context, listen: false);
      String idJadwal = widget.jadwal['id'].toString();

      List<dynamic> allSeats = await provider.getKursi(val, '');
      List<dynamic> availableSeats = await provider.getKursi(val, idJadwal);

      Set<String> availIds = availableSeats.map((e) => e['id'].toString()).toSet();
      List<String> occupiedList = [];

      for (var s in allSeats) {
        String sId = s['id'].toString();
        if (!availIds.contains(sId)) {
          occupiedList.add(sId); 
        }
      }

      setState(() {
        _allSeatsInGerbong = allSeats;
        _occupiedSeatIds = occupiedList;
        _isLoadingKursi = false;
      });
    }
  }

  // 4. BUKA MODAL SEAT MAP
  void _openSeatMap() {
    if (_selectedGerbong == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon tunggu, memuat gerbong..."))
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9, 
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  // Header Modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pilih Kursi",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(),
                  
                  // Pilihan Gerbong di dalam Modal
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGerbong,
                        isExpanded: true,
                        items: _listGerbong.map((g) => DropdownMenuItem(
                          value: g['id'].toString(),
                          child: Text(g['nama_gerbong']),
                        )).toList(),
                        onChanged: (val) {
                          Navigator.pop(context); // Tutup dulu
                          _onGerbongChanged(val); // Ganti gerbong
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () => _openSeatMap(),
                          ); // Buka lagi
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Denah Kursi
                  Expanded(
                    child: _isLoadingKursi 
                    ? const Center(child: CircularProgressIndicator())
                    : SeatMapWidget(
                        allSeats: _allSeatsInGerbong,
                        occupiedSeats: _occupiedSeatIds,
                        selectedSeats: _mySelectedSeatIds,
                        passengerCount: widget.passengerCount,
                        onSeatSelected: (newSelection) {
                          setModalState(() {
                            _mySelectedSeatIds = newSelection;
                          });
                        },
                      ),
                  ),

                  // Footer Modal
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                      ),
                      onPressed: () {
                        if (_mySelectedSeatIds.length != widget.passengerCount) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              "Pilih ${widget.passengerCount} kursi untuk melanjutkan!"
                            ),
                          ));
                          return;
                        }

                        setState(() {
                           // Mapping Kursi ke Penumpang
                           for (int i = 0; i < _passengers.length; i++) {
                             _passengers[i]['kursi'] = _mySelectedSeatIds[i];
                           }
                        });
                        Navigator.pop(context); 
                      },
                      child: Text(
                        "SIMPAN (${_mySelectedSeatIds.length}/${widget.passengerCount})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  // 5. SUBMIT ORDER DENGAN VALIDASI
  void _submitOrder() async {
    // Reset error messages
    setState(() {
      for (var p in _passengers) {
        p['nik_error'] = null;
        p['nama_error'] = null;
      }
    });

    // Validasi semua penumpang
    bool hasError = false;
    for (int i = 0; i < _passengers.length; i++) {
      var p = _passengers[i];
      bool isMainUser = p['is_user'] == true;
      
      // Validasi NIK
      String? nikError = _validateNIK(p['nik'].text, isMainUser);
      if (nikError != null) {
        setState(() {
          p['nik_error'] = nikError;
        });
        hasError = true;
      }
      
      // Validasi Nama
      String? namaError = _validateNama(p['nama'].text, isMainUser);
      if (namaError != null) {
        setState(() {
          p['nama_error'] = namaError;
        });
        hasError = true;
      }
      
      // Validasi Kursi
      if (p['kursi'] == null) {
        hasError = true;
      }
    }

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi dan perbaiki Data Penumpang & Pilih Kursi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final booking = Provider.of<BookingProvider>(context, listen: false);

    // Payload
    List<Map<String, dynamic>> payload = _passengers.map((p) {
      return {
        'nik': p['nik'].text.replaceAll(RegExp(r'\D'), ''), // Kirim hanya angka
        'nama': p['nama'].text.trim(),
        'id_kursi': p['kursi'],
      };
    }).toList();

    // API Call
    final result = await booking.orderTiket(
      idPelanggan: user!.idPelanggan!,
      idJadwal: widget.jadwal['id'],
      penumpang: payload,
    );

    if (result['status'] == 'success') {
      int idPembelian = int.parse(result['id_pembelian'].toString());
      int hargaSatuan = int.parse(widget.jadwal['harga'].toString());
      int totalHarga = hargaSatuan * widget.passengerCount;

      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PaymentScreen(
          idPembelian: idPembelian,
          totalHarga: totalHarga,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${result['message']}")),
      );
    }
  }

  // Helper tampilan nomor kursi
  String _getSeatDisplay(String? id) {
    if (id == null) return "Belum dipilih";
    try {
      // Cari kursi di gerbong saat ini
      var seat = _allSeatsInGerbong.firstWhere(
        (e) => e['id'].toString() == id,
        orElse: () => null,
      );
      if (seat != null) return "${seat['no_kursi']}";
      return "Terpilih"; // Fallback jika ganti gerbong visualnya hilang tapi datanya ada
    } catch (e) {
      return "?";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hitung Total
    int hargaSatuan = int.parse(widget.jadwal['harga'].toString());
    int totalHarga = hargaSatuan * widget.passengerCount;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Pesan Tiket",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ), 
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. STEPPER & HEADER (Background Biru)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStepItem("1", "Pesan", true),
                _buildLine(true),
                _buildStepItem("2", "Bayar", false),
                _buildLine(false),
                _buildStepItem("3", "Selesai", false),
              ],
            ),
          ),

          // 2. CONTENT SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD DETAIL KERETA
                  _buildTrainDetailCard(),
                  const SizedBox(height: 20),

                  // HEADER DATA PENUMPANG
                  const Text(
                    "Data Penumpang",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  // LIST FORM PENUMPANG
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _passengers.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                    itemBuilder: (ctx, i) => _buildPassengerForm(i),
                  ),

                  const SizedBox(height: 20),

                  // CARD PILIH KURSI
                  _buildSeatSelectionCard(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 3. FOOTER TOTAL & TOMBOL
          _buildBottomBar(totalHarga),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildStepItem(String num, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? kSecondaryColor : Colors.white24,
            shape: BoxShape.circle
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        )
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? kSecondaryColor : Colors.white24,
        margin: const EdgeInsets.symmetric(horizontal: 5),
      ),
    );
  }

  Widget _buildTrainDetailCard() {
    // Parsing Tanggal & Jam
    DateTime dt = DateTime.parse(widget.jadwal['tanggal_berangkat']);
    String dateStr = DateFormat('EEE, d MMM yyyy').format(dt);
    String timeStr = DateFormat('HH:mm').format(dt);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.jadwal['nama_kereta'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                dateStr,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jadwal['asal_keberangkatan'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Expanded(
                child: Icon(Icons.arrow_right_alt, color: Colors.grey),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.jadwal['tujuan_keberangkatan'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Tiba",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPassengerForm(int index) {
    var p = _passengers[index];
    bool isSeatSelected = p['kursi'] != null;
    bool isMainUser = p['is_user'] == true;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Penumpang ${index + 1}",
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (index == 0) const Text(
                "Dewasa",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Divider(),
          
          // Input Nama dengan validasi
          TextField(
            controller: p['nama'],
            readOnly: isMainUser,
            style: const TextStyle(fontWeight: FontWeight.bold),
            inputFormatters: isMainUser ? null : [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            ],
            decoration: InputDecoration(
              labelText: "Nama Lengkap",
              labelStyle: const TextStyle(fontSize: 12),
              errorText: p['nama_error'],
              hintText: isMainUser ? null : "Hanya huruf dan spasi",
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 10),
          
          // Input NIK dengan validasi
          TextField(
            controller: p['nik'],
            readOnly: isMainUser,
            keyboardType: TextInputType.number,
            maxLength: 16,
            inputFormatters: isMainUser ? null : [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: "Nomor Identitas (NIK)",
              labelStyle: const TextStyle(fontSize: 12),
              errorText: p['nik_error'],
              hintText: isMainUser ? null : "16 digit",
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: '', // Hide character counter
            ),
          ),
          const SizedBox(height: 10),
          
          // Info Kursi per Penumpang
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSeatSelected ? Colors.blue[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_seat,
                  size: 16,
                  color: isSeatSelected ? kPrimaryColor : Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  isSeatSelected
                      ? "Kursi: ${_getSeatDisplay(p['kursi'])}"
                      : "Kursi belum dipilih",
                  style: TextStyle(
                    fontSize: 12,
                    color: isSeatSelected ? kPrimaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSeatSelectionCard() {
    bool allSeatsSelected = _passengers.every((p) => p['kursi'] != null);

    return InkWell(
      onTap: _openSeatMap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: allSeatsSelected ? kPrimaryColor : Colors.orange,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.grid_on, color: kPrimaryColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Kursi",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    allSeatsSelected
                        ? "Semua kursi terpilih"
                        : "Ketuk untuk memilih kursi", 
                    style: TextStyle(
                      color: allSeatsSelected ? kPrimaryColor : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ),
            const Icon(Icons.chevron_right, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(int totalHarga) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Harga",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "Rp $totalHarga",
                style: const TextStyle(
                  color: kSecondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: Provider.of<BookingProvider>(context).isLoading
                ? null
                : _submitOrder,
            child: const Text(
              "LANJUTKAN",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var p in _passengers) {
      p['nik'].dispose();
      p['nama'].dispose();
    }
    super.dispose();
  }
}