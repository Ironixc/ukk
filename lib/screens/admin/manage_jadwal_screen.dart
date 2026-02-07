import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../providers/admin_provider.dart';

class ManageJadwalScreen extends StatefulWidget {
  @override
  _ManageJadwalScreenState createState() => _ManageJadwalScreenState();
}

class _ManageJadwalScreenState extends State<ManageJadwalScreen> {
  @override
  void initState() {
    super.initState();
    final admin = Provider.of<AdminProvider>(context, listen: false);
    admin.getJadwal();
    admin.getKereta(); // Fetch trains to populate the dropdown
  }

  //LIST FROM HOME SCREEN
  final List<String> stations = ["Gambir", "Bandung", "Surabaya Gubeng", "Malang", "Yogyakarta", "Solo Balapan", "Semarang Tawang"];

  void _showAddDialog() {
    String? _selectedKereta;
    String _asal = stations[0];
    String _tujuan = stations[1];
    DateTime _date = DateTime.now();
    TimeOfDay _timeBerangkat = TimeOfDay.now();
    TimeOfDay _timeTiba = TimeOfDay(hour: _timeBerangkat.hour + 4, minute: _timeBerangkat.minute);
    final _harga = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final keretaList = Provider.of<AdminProvider>(context, listen: false).listKereta;
          
          return AlertDialog(
            title: Text("Add Schedule"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Train Info", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  DropdownButtonFormField(
                    value: _selectedKereta,
                    hint: Text("Select Train"),
                    isExpanded: true,
                    items: keretaList.map<DropdownMenuItem<String>>((k) {
                      return DropdownMenuItem(value: k['id'].toString(), child: Text(k['nama_kereta']));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedKereta = v.toString()),
                  ),
                  SizedBox(height: 15),

                  Text("Route", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          value: _asal,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: "Origin"),
                          items: stations.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 13)))).toList(),
                          onChanged: (v) => setState(() => _asal = v.toString()),
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField(
                          value: _tujuan,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: "Destination"),
                          items: stations.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 13)))).toList(),
                          onChanged: (v) => setState(() => _tujuan = v.toString()),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  Text("Date & Time", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Date: ${DateFormat('yyyy-MM-dd').format(_date)}"),
                    trailing: Icon(Icons.calendar_month, color: kPrimaryColor),
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime(2030));
                      if (d != null) setState(() => _date = d);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          child: Text("Dep: ${_timeBerangkat.format(context)}"),
                          onPressed: () async {
                            final t = await showTimePicker(context: context, initialTime: _timeBerangkat);
                            if (t != null) setState(() => _timeBerangkat = t);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          child: Text("Arr: ${_timeTiba.format(context)}"),
                          onPressed: () async {
                            final t = await showTimePicker(context: context, initialTime: _timeTiba);
                            if (t != null) setState(() => _timeTiba = t);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  TextField(controller: _harga, decoration: InputDecoration(labelText: "Price (Rp)", border: OutlineInputBorder()), keyboardType: TextInputType.number),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                onPressed: () async {
                  if (_selectedKereta == null || _harga.text.isEmpty) return;
                  
                  // Format for MySQL (YYYY-MM-DD HH:MM:SS)
                  String dtBerangkat = "${DateFormat('yyyy-MM-dd').format(_date)} ${_timeBerangkat.hour}:${_timeBerangkat.minute}:00";
                  String dtTiba = "${DateFormat('yyyy-MM-dd').format(_date)} ${_timeTiba.hour}:${_timeTiba.minute}:00";

                  Map<String, dynamic> payload = {
                    'id_kereta': _selectedKereta.toString(),
                    'asal_keberangkatan': _asal,
                    'tujuan_keberangkatan': _tujuan,
                    'tanggal_berangkat': dtBerangkat,
                    'tanggal_kedatangan': dtTiba,
                    'harga': _harga.text
                  };

                  await Provider.of<AdminProvider>(context, listen: false).addJadwal(payload);
                  Navigator.pop(ctx);
                }, 
                child: Text("Save Schedule")
              )
            ],
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Manage Schedules", style: TextStyle(color: Colors.black87)), 
        backgroundColor: Colors.white, 
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.orange,
        icon: Icon(Icons.add),
        label: Text("Add Schedule"),
      ),
      body: Consumer<AdminProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: provider.listJadwal.length,
            separatorBuilder: (ctx, i) => SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final item = provider.listJadwal[i];
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['nama_kereta'], style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
                          Text("Rp ${item['harga']}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                      Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Origin", style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(item['asal_keberangkatan'], style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(item['tanggal_berangkat'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                          Icon(Icons.arrow_right_alt, color: Colors.grey[400]),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Destination", style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(item['tujuan_keberangkatan'], style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(item['tanggal_kedatangan'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => provider.deleteJadwal(item['id'].toString()),
                          icon: Icon(Icons.delete, size: 16, color: Colors.red),
                          label: Text("Remove", style: TextStyle(color: Colors.red)),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(50, 30)),
                        ),
                      )
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