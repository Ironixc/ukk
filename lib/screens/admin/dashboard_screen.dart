import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk/screens/admin/manage_jadwal_screen.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';
import 'manage_kereta_screen.dart'; // Kita buat setelah ini

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context);
    String namaPetugas = auth.currentUser?.username ?? "Petugas";

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Admin"),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Logout Logic
              Provider.of<AuthProvider>(
                context,
                listen: false,
              ).logout(); // Buat fungsi logout di AuthProvider nanti
              Navigator.of(context).pushReplacementNamed('/'); // Balik ke Login
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: EdgeInsets.all(20),
            color: kPrimaryColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $namaPetugas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Kelola sistem tiket dari sini",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Grid Menu
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildMenu(
                  context,
                  "Data Kereta",
                  Icons.train,
                  Colors.blue,
                  ManageKeretaScreen(),
                ),
                _buildMenu(
                  context,
                  "Data Gerbong",
                  Icons.chair_alt,
                  Colors.orange,
                  null,
                ), // Nanti dibuat
                _buildMenu(
                  context,
                  "Jadwal",
                  Icons.calendar_today,
                  Colors.green,
                  ManageJadwalScreen(),
                ),
                _buildMenu(
                  context,
                  "Laporan",
                  Icons.analytics,
                  Colors.purple,
                  null,
                ), // Nanti dibuat
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? page,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Fitur belum tersedia")));
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
