import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_report_provider.dart';
import '../../constants.dart';

class HistoryAdmin extends StatefulWidget {
  @override
  _HistoryAdminState createState() => _HistoryAdminState();
}

class _HistoryAdminState extends State<HistoryAdmin> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<AdminReportProvider>(context, listen: false).getAllHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("History Transaksi", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Consumer<AdminReportProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.allTransactions.isEmpty) return Center(child: Text("Belum ada transaksi"));

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: provider.allTransactions.length,
            separatorBuilder: (ctx, i) => SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final item = provider.allTransactions[i];
              
              // Logika Adaptasi: Ambil nama dari detail_penumpang jika nama_lengkap null
              String customerName = "Customer";
              if (item['detail_penumpang'] != null && item['detail_penumpang'].isNotEmpty) {
                customerName = item['detail_penumpang'][0]['nama_penumpang'];
              }

              bool isLunas = item['status_pembayaran'] == 'lunas';

              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Gunakan item['id'] sesuai dengan JSON backend Anda
                        Text("Order ID: #${item['id']}", style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
                        _buildStatusBadge(isLunas, item['status_pembayaran'] ?? 'pending'),
                      ],
                    ),
                    Divider(height: 24),
                    Text(customerName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.train, size: 14, color: Colors.grey),
                        SizedBox(width: 5),
                        Text("${item['nama_kereta']} (${item['asal_keberangkatan']} ➝ ${item['tujuan_keberangkatan']})", 
                          style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['tanggal_pembelian'] ?? "", style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text("Rp ${item['total_harga']}", style: TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool isLunas, String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLunas ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isLunas ? Colors.green : Colors.orange, width: 0.5)
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: isLunas ? Colors.green[700] : Colors.orange[800], fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}