import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../constants.dart';

class ManageKeretaScreen extends StatefulWidget {
  @override
  _ManageKeretaScreenState createState() => _ManageKeretaScreenState();
}

class _ManageKeretaScreenState extends State<ManageKeretaScreen> {
  @override
  void initState() {
    super.initState();
    // Load data otomatis saat halaman dibuka
    Future.microtask(() => 
      Provider.of<AdminProvider>(context, listen: false).getKereta()
    );
  }

  // ---------------------------------------------------------------------------
  // LOGIKA UTAMA FORM DIALOG (TAMBAH / EDIT)
  // ---------------------------------------------------------------------------
  void _showFormDialog({Map? item}) {
    // Controller Text Input
    final _nameController = TextEditingController(text: item != null ? item['nama_kereta'] : '');
    final _descController = TextEditingController(text: item != null ? item['deskripsi'] : '');
    
    // Controller Gerbong & Kuota
    // Ambil data jumlah gerbong aktif jika ada, default 1
    final _gerbongController = TextEditingController(
      text: item != null && item['jumlah_gerbong_aktif'] != null 
          ? item['jumlah_gerbong_aktif'].toString() 
          : '1'
    );
    final _kuotaController = TextEditingController(text: '50'); // Default 50 kursi

    // --- LOGIC PERBAIKAN DROPDOWN (CASE INSENSITIVE) ---
    List<String> opsiKelas = ['Ekonomi', 'Bisnis', 'Eksekutif'];
    String _selectedKelas = 'Ekonomi'; // Default aman

    if (item != null && item['kelas'] != null) {
      String dbKelas = item['kelas'].toString();
      try {
        // Cari yg cocok (abaikan huruf besar/kecil). 
        // Misal DB "ekonomi" -> Ketemu "Ekonomi" di list -> Pakai "Ekonomi"
        _selectedKelas = opsiKelas.firstWhere(
          (opsi) => opsi.toLowerCase() == dbKelas.toLowerCase(),
          orElse: () => 'Ekonomi', // Jika data aneh, balik ke Ekonomi
        );
      } catch (e) {
        _selectedKelas = 'Ekonomi';
      }
    }
    // ---------------------------------------------------

    showDialog(
      context: context,
      builder: (ctx) {
        // Kita pakai StatefulBuilder AGAR Dropdown bisa berubah tampilan saat diklik
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(item == null ? "Tambah Kereta Baru" : "Edit Kereta"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Nama
                    TextField(
                      controller: _nameController, 
                      decoration: InputDecoration(
                        labelText: "Nama Kereta", 
                        hintText: "Cth: Argo Wilis",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                      )
                    ),
                    SizedBox(height: 10),
                    
                    // Input Deskripsi
                    TextField(
                      controller: _descController, 
                      decoration: InputDecoration(
                        labelText: "Deskripsi / Rute",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                      )
                    ),
                    SizedBox(height: 10),
                    
                    // Input Dropdown Kelas (FIXED)
                    DropdownButtonFormField<String>(
                      value: _selectedKelas,
                      decoration: InputDecoration(
                        labelText: "Kelas Kereta",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                      ),
                      items: opsiKelas.map((String val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() { // Update tampilan dialog lokal
                          _selectedKelas = val!;
                        });
                      },
                    ),
                    
                    SizedBox(height: 20),
                    Divider(thickness: 2),
                    Text("Konfigurasi Gerbong Otomatis", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kPrimaryColor)),
                    SizedBox(height: 10),

                    Row(
                      children: [
                        // Input Jumlah Gerbong
                        Expanded(
                          child: TextField(
                            controller: _gerbongController, 
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Jml Gerbong", 
                              helperText: "Total Gerbong",
                              border: OutlineInputBorder()
                            )
                          ),
                        ),
                        SizedBox(width: 15),
                        
                        // Input Kuota (Hanya muncul saat Tambah Baru)
                        // Agar logic Edit tidak terlalu rumit merubah struktur kursi lama
                        item == null ? Expanded(
                          child: TextField(
                            controller: _kuotaController, 
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Kursi", 
                              helperText: "Per Gerbong",
                              border: OutlineInputBorder()
                            )
                          ),
                        ) : Container(),
                      ],
                    ),
                    
                    if (item != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.orange)
                          ),
                          child: Text(
                            "Perhatian: Mengurangi jumlah gerbong akan menghapus gerbong nomor terakhir beserta kursinya secara permanen.",
                            style: TextStyle(color: Colors.orange[800], fontSize: 11),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), 
                  child: Text("Batal", style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  onPressed: () async {
                    // Validasi Sederhana
                    if (_nameController.text.isEmpty || _gerbongController.text.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nama & Jumlah Gerbong wajib diisi")));
                       return;
                    }

                    Navigator.pop(ctx); // Tutup dialog

                    // Tampilkan Loading
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sedang memproses..."), duration: Duration(seconds: 1)));

                    bool success;
                    final provider = Provider.of<AdminProvider>(context, listen: false);

                    if (item == null) {
                      // Mode Tambah
                      success = await provider.addKereta(
                        _nameController.text, 
                        _descController.text, 
                        _selectedKelas,
                        _gerbongController.text,
                        _kuotaController.text
                      );
                    } else {
                      // Mode Edit
                      success = await provider.updateKereta(
                        item['id'], 
                        _nameController.text, 
                        _descController.text, 
                        _selectedKelas,
                        _gerbongController.text
                      );
                    }

                    // Feedback
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? "Berhasil disimpan!" : "Gagal menyimpan data"), 
                          backgroundColor: success ? Colors.green : Colors.red
                        )
                      );
                    }
                  },
                  child: Text("Simpan & Proses"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TAMPILAN UTAMA (LIST KERETA)
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kelola Data Kereta"), 
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kSecondaryColor,
        icon: Icon(Icons.add),
        label: Text("Tambah Kereta"),
        onPressed: () => _showFormDialog(), // Buka form tambah
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          // 1. Loading State
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // 2. Empty State
          if (provider.listKereta.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.train_outlined, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 10),
                  Text("Belum ada data kereta.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 3. List Data State
          return RefreshIndicator(
            onRefresh: () => provider.getKereta(),
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 80), // Biar gak ketutup FAB
              itemCount: provider.listKereta.length,
              itemBuilder: (context, index) {
                final item = provider.listKereta[index];
                
                // Ambil info jumlah gerbong (handle jika null)
                String infoGerbong = item['jumlah_gerbong_aktif'] != null 
                    ? "${item['jumlah_gerbong_aktif']} Gerbong" 
                    : "- Gerbong";

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: kPrimaryColor.withOpacity(0.1),
                      child: Icon(Icons.train, color: kPrimaryColor),
                    ),
                    title: Text(
                      item['nama_kereta'], 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        // Badge Kelas
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            item['kelas'], 
                            style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.bold)
                          ),
                        ),
                        SizedBox(height: 4),
                        Text("$infoGerbong • ${item['deskripsi']}", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Edit
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.grey),
                          onPressed: () => _showFormDialog(item: item),
                        ),
                        // Tombol Hapus
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[300]),
                          onPressed: () async {
                            // Konfirmasi Hapus
                            bool confirm = await showDialog(
                              context: context, 
                              builder: (ctx) => AlertDialog(
                                title: Text("Hapus ${item['nama_kereta']}?"),
                                content: Text("Data yang dihapus tidak bisa dikembalikan."),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Batal")),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Hapus", style: TextStyle(color: Colors.red))),
                                ],
                              )
                            ) ?? false;

                            if (confirm) {
                              String result = await provider.deleteKereta(item['id']);
                              if (result != "success") {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data dihapus")));
                              }
                            }
                          },
                        ),
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