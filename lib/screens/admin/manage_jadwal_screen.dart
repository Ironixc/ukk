import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Wajib tambahkan: flutter pub add intl
import '../../providers/admin_provider.dart';
import '../../constants.dart';

class ManageJadwalScreen extends StatefulWidget {
  const ManageJadwalScreen({super.key});

  @override
  _ManageJadwalScreenState createState() => _ManageJadwalScreenState();
}

class _ManageJadwalScreenState extends State<ManageJadwalScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.getJadwal();
      provider.getKereta(); // Kita butuh data kereta untuk Dropdown
    });
  }

  // Helper untuk Memilih Tanggal & Waktu
  Future<String?> _pickDateTime(BuildContext context, {String? initial}) async {
    DateTime now = DateTime.now();
    DateTime initDate = initial != null ? DateTime.parse(initial) : now;

    // 1. Pilih Tanggal
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date == null) return null;

    // 2. Pilih Jam
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initDate),
    );
    if (time == null) return null;

    // 3. Gabungkan jadi Format MySQL: yyyy-MM-dd HH:mm:ss
    final DateTime fullDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(fullDateTime);
  }

  void _showFormDialog({Map? item}) {
    final asalController = TextEditingController(text: item != null ? item['asal_keberangkatan'] : '');
    final tujuanController = TextEditingController(text: item != null ? item['tujuan_keberangkatan'] : '');
    final hargaController = TextEditingController(text: item != null ? item['harga'].toString() : '');
    
    // Variabel state lokal untuk dropdown & tanggal
    String? selectedKeretaId = item != null ? item['id_kereta'].toString() : null;
    String tglBerangkat = item != null ? item['tanggal_berangkat'] : '';
    String tglDatang = item != null ? item['tanggal_kedatangan'] : '';

    // Ambil list kereta dari provider untuk dropdown
    final listKereta = Provider.of<AdminProvider>(context, listen: false).listKereta;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(item == null ? "Tambah Jadwal" : "Edit Jadwal"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown Kereta
                    DropdownButtonFormField<String>(
                      initialValue: selectedKeretaId,
                      hint: Text("Pilih Kereta"),
                      items: listKereta.map((k) {
                        return DropdownMenuItem(
                          value: k['id'].toString(),
                          child: Text("${k['nama_kereta']} (${k['kelas']})"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() => selectedKeretaId = val);
                      },
                      decoration: InputDecoration(labelText: "Kereta", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),

                    // Asal & Tujuan
                    Row(
                      children: [
                        Expanded(child: TextField(controller: asalController, decoration: InputDecoration(labelText: "Stasiun Asal"))),
                        SizedBox(width: 10),
                        Expanded(child: TextField(controller: tujuanController, decoration: InputDecoration(labelText: "Stasiun Tujuan"))),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Input Harga
                    TextField(
                      controller: hargaController, 
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Harga Tiket (Rp)", prefixText: "Rp ", border: OutlineInputBorder())
                    ),
                    SizedBox(height: 15),

                    // Picker Tanggal Berangkat
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Berangkat: ${tglBerangkat.isEmpty ? 'Pilih Tanggal' : tglBerangkat}"),
                      trailing: Icon(Icons.calendar_today, color: kPrimaryColor),
                      onTap: () async {
                        String? res = await _pickDateTime(context, initial: tglBerangkat.isNotEmpty ? tglBerangkat : null);
                        if (res != null) setStateDialog(() => tglBerangkat = res);
                      },
                    ),
                    Divider(),
                    
                    // Picker Tanggal Datang
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Tiba: ${tglDatang.isEmpty ? 'Pilih Tanggal' : tglDatang}"),
                      trailing: Icon(Icons.timer, color: kPrimaryColor),
                      onTap: () async {
                        String? res = await _pickDateTime(context, initial: tglDatang.isNotEmpty ? tglDatang : null);
                        if (res != null) setStateDialog(() => tglDatang = res);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  onPressed: () async {
                    if (selectedKeretaId == null || tglBerangkat.isEmpty || asalController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data tidak lengkap")));
                      return;
                    }

                    Navigator.pop(ctx);
                    
                    final dataToSend = {
                      'asal_keberangkatan': asalController.text,
                      'tujuan_keberangkatan': tujuanController.text,
                      'harga': hargaController.text,
                      'id_kereta': selectedKeretaId,
                      'tanggal_berangkat': tglBerangkat,
                      'tanggal_kedatangan': tglDatang,
                    };

                    bool success;
                    final provider = Provider.of<AdminProvider>(context, listen: false);

                    if (item == null) {
                      success = await provider.addJadwal(dataToSend);
                    } else {
                      success = await provider.updateJadwal(item['id'], dataToSend);
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? "Sukses" : "Gagal"), backgroundColor: success ? Colors.green : Colors.red)
                      );
                    }
                  },
                  child: Text("Simpan"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kelola Jadwal Perjalanan"), backgroundColor: kPrimaryColor),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kSecondaryColor,
        child: Icon(Icons.add),
        onPressed: () => _showFormDialog(),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.listJadwal.isEmpty) return Center(child: Text("Belum ada jadwal."));

          return RefreshIndicator(
            onRefresh: () => provider.getJadwal(),
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 80),
              itemCount: provider.listJadwal.length,
              itemBuilder: (context, index) {
                final item = provider.listJadwal[index];
                // Format tanggal agar cantik (optional)
                // final fmtDate = DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(item['tanggal_berangkat']));

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['nama_kereta'] ?? 'Unknown Train', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Rp ${item['harga']}", style: TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor)),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Berangkat", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                  Text(item['asal_keberangkatan'], style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(item['tanggal_berangkat'], style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward, color: Colors.grey),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Tiba", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                  Text(item['tujuan_keberangkatan'], style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(item['tanggal_kedatangan'], style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFormDialog(item: item),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                String res = await provider.deleteJadwal(item['id']);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}