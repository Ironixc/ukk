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
    final _kuota = TextEditingController();
    String _kelas = "Eksekutif";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Add New Train"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nama, decoration: InputDecoration(labelText: "Train Name (e.g. Argo Bromo)", border: OutlineInputBorder())),
              SizedBox(height: 10),
              DropdownButtonFormField(
                value: _kelas,
                items: ["Eksekutif", "Bisnis", "Ekonomi"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => _kelas = v.toString(),
                decoration: InputDecoration(labelText: "Class", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(controller: _gerbong, decoration: InputDecoration(labelText: "Total Carriages", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              SizedBox(height: 10),
              TextField(controller: _kuota, decoration: InputDecoration(labelText: "Seats per Carriage", border: OutlineInputBorder()), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () async {
              if (_nama.text.isEmpty || _gerbong.text.isEmpty) return;
              await Provider.of<AdminProvider>(context, listen: false)
                  .addKereta(_nama.text, "Standard Description", _kelas, _gerbong.text, _kuota.text);
              Navigator.pop(ctx);
            }, 
            child: Text("Save")
          )
        ],
      )
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final _nama = TextEditingController(text: item['nama_kereta']);
    final _gerbong = TextEditingController(text: item['jumlah_gerbong_aktif'].toString());
    final _kuota = TextEditingController(text: "50"); // Default kuota
    String _kelas = item['kelas'] ?? "Eksekutif";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Edit Train"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _nama, decoration: InputDecoration(labelText: "Train Name", border: OutlineInputBorder())),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  value: _kelas,
                  items: ["Eksekutif", "Bisnis", "Ekonomi"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _kelas = v.toString()),
                  decoration: InputDecoration(labelText: "Class", border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                TextField(controller: _gerbong, decoration: InputDecoration(labelText: "Total Carriages", border: OutlineInputBorder()), keyboardType: TextInputType.number),
                SizedBox(height: 10),
                TextField(controller: _kuota, decoration: InputDecoration(labelText: "Seats per Carriage", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () async {
                if (_nama.text.isEmpty || _gerbong.text.isEmpty) return;
                await Provider.of<AdminProvider>(context, listen: false)
                    .updateKereta(item['id'].toString(), _nama.text, item['deskripsi'] ?? "Standard Description", _kelas, _gerbong.text);
                Navigator.pop(ctx);
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
          
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: provider.listKereta.length,
            separatorBuilder: (ctx, i) => SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final item = provider.listKereta[i];
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[50], 
                    child: Text(item['nama_kereta'][0].toUpperCase(), style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
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
                          final result = await provider.deleteKereta(item['id'].toString());
                          if (result != "success") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              )
                            );
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