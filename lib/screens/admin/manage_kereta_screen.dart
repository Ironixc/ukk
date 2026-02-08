import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/admin_provider.dart';

class ManageKeretaScreen extends StatefulWidget {
  @override
  _ManageKeretaScreenState createState() => _ManageKeretaScreenState();
}

class _ManageKeretaScreenState extends State<ManageKeretaScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<AdminProvider>(context, listen: false).getKereta());
  }

  void _showAddDialog() {
    final _nama = TextEditingController();
    final _gerbong = TextEditingController();
    final _kuota = TextEditingController(text: "50");
    String _kelas = "Eksekutif";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Add New Train"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nama, 
                  decoration: InputDecoration(
                    labelText: "Train Name (e.g. Argo Bromo)", 
                    border: OutlineInputBorder()
                  )
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _kelas,
                  items: ["Eksekutif", "Bisnis", "Ekonomi"]
                    .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                  onChanged: (v) => setDialogState(() => _kelas = v!),
                  decoration: InputDecoration(labelText: "Class", border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _gerbong, 
                  decoration: InputDecoration(
                    labelText: "Total Carriages", 
                    border: OutlineInputBorder()
                  ), 
                  keyboardType: TextInputType.number
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _kuota, 
                  decoration: InputDecoration(
                    labelText: "Seats per Carriage", 
                    border: OutlineInputBorder(),
                    helperText: "Jumlah kursi di setiap gerbong"
                  ), 
                  keyboardType: TextInputType.number
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: Text("Cancel")
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () async {
                if (_nama.text.isEmpty || _gerbong.text.isEmpty || _kuota.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Semua field harus diisi!"), backgroundColor: Colors.red)
                  );
                  return;
                }
                
                final success = await Provider.of<AdminProvider>(context, listen: false)
                    .addKereta(_nama.text, "Standard Description", _kelas, _gerbong.text, _kuota.text);
                
                Navigator.pop(ctx);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Kereta berhasil ditambahkan!"), backgroundColor: Colors.green)
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menambahkan kereta"), backgroundColor: Colors.red)
                  );
                }
              }, 
              child: Text("Save")
            )
          ],
        ),
      )
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final _nama = TextEditingController(text: item['nama_kereta']);
    final _gerbong = TextEditingController(text: item['jumlah_gerbong_aktif'].toString());
    final _kuota = TextEditingController(text: "50");
    String _kelas = item['kelas'] ?? "Eksekutif";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Edit Train"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nama, 
                  decoration: InputDecoration(
                    labelText: "Train Name", 
                    border: OutlineInputBorder()
                  )
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _kelas,
                  items: ["Eksekutif", "Bisnis", "Ekonomi"]
                    .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                  onChanged: (v) => setDialogState(() => _kelas = v!),
                  decoration: InputDecoration(labelText: "Class", border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _gerbong, 
                  decoration: InputDecoration(
                    labelText: "Total Carriages", 
                    border: OutlineInputBorder(),
                    helperText: "Gerbong saat ini: ${item['jumlah_gerbong_aktif']}"
                  ), 
                  keyboardType: TextInputType.number
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _kuota, 
                  decoration: InputDecoration(
                    labelText: "Seats per New Carriage", 
                    border: OutlineInputBorder(),
                    helperText: "Hanya berlaku untuk gerbong BARU yang ditambahkan"
                  ), 
                  keyboardType: TextInputType.number
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Kuota hanya digunakan jika menambah gerbong baru",
                          style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: Text("Cancel")
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () async {
                if (_nama.text.isEmpty || _gerbong.text.isEmpty || _kuota.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Semua field harus diisi!"), backgroundColor: Colors.red)
                  );
                  return;
                }
                
                final success = await Provider.of<AdminProvider>(context, listen: false)
                    .updateKereta(
                      item['id'].toString(), 
                      _nama.text, 
                      item['deskripsi'] ?? "Standard Description", 
                      _kelas, 
                      _gerbong.text,
                      _kuota.text
                    );
                
                Navigator.pop(ctx);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Kereta berhasil diupdate!"), backgroundColor: Colors.green)
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal update kereta"), backgroundColor: Colors.red)
                  );
                }
              }, 
              child: Text("Update")
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Manage Trains", style: TextStyle(color: Colors.black87)), 
        backgroundColor: Colors.white, 
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blueAccent,
        icon: Icon(Icons.add),
        label: Text("Add Train"),
      ),
      body: Consumer<AdminProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          
          if (provider.listKereta.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.train, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text("Belum ada data kereta", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Text("Tap tombol + untuk menambahkan", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            );
          }
          
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: provider.listKereta.length,
            separatorBuilder: (ctx, i) => SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final item = provider.listKereta[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(10), 
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[50], 
                    child: Text(
                      item['nama_kereta'][0].toUpperCase(), 
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                    )
                  ),
                  title: Text(item['nama_kereta'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${item['kelas']} • ${item['jumlah_gerbong_aktif'] ?? 0} Carriages"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blue[300]),
                        onPressed: () => _showEditDialog(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text("Konfirmasi Hapus"),
                              content: Text("Yakin ingin menghapus kereta ${item['nama_kereta']}?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text("Batal"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text("Hapus"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final result = await provider.deleteKereta(item['id'].toString());
                            if (result != "success") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                )
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Kereta berhasil dihapus"),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                )
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}