import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_report_provider.dart';

class Income extends StatefulWidget {
  @override
  _IncomeState createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<AdminReportProvider>(context, listen: false).getMonthlyRecap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Pemasukan Bulanan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Consumer<AdminReportProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.monthlyRecap.isEmpty) return Center(child: Text("Tidak ada data pemasukan (hanya status lunas yang dihitung)"));

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: provider.monthlyRecap.length,
            separatorBuilder: (ctx, i) => SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final item = provider.monthlyRecap[i];

              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))]
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                      child: Icon(Icons.account_balance_wallet, color: Colors.green),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Menggunakan key 'bulan' sesuai JSON backend
                          Text(item['bulan'] ?? "Unknown Month", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("${item['total_transaksi']} Tiket Terjual", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    // Menggunakan key 'total_pemasukan' sesuai JSON backend
                    Text(
                      "Rp ${item['total_pemasukan'] ?? "0"}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
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
}