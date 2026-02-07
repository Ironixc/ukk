import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  
  // --- DIALOG EDIT PROFIL ---
  void _showEditProfileDialog() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final _namaController = TextEditingController(text: user?.namaLengkap);
    final _alamatController = TextEditingController(text: "Alamat belum diset"); 
    final _telpController = TextEditingController(text: "0812xxxx"); 

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Profil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _namaController, decoration: InputDecoration(labelText: "Nama Lengkap")),
            TextField(controller: _alamatController, decoration: InputDecoration(labelText: "Alamat")),
            TextField(controller: _telpController, decoration: InputDecoration(labelText: "No. Telepon")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal")),
 

          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          //   onPressed: () async {
          //     if (_namaController.text.isEmpty) {
          //        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nama tidak boleh kosong")));
          //        return;
          //     }

          //     final result = await Provider.of<AuthProvider>(context, listen: false)
          //         .updateProfile(_namaController.text, _alamatController.text, _telpController.text);
              
          //     Navigator.pop(ctx);

          //     if (result['success']) {
          //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //         content: Text(result['message']),
          //         backgroundColor: Colors.green,
          //       ));
          //     } else {
          //       // TAMPILKAN PESAN ERROR ASLI DARI SERVER DISINI
          //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //         content: Text("Gagal: ${result['message']}"),
          //         backgroundColor: Colors.red,
          //         duration: Duration(seconds: 4),
          //       ));
          //     }
          //   }, 
          //   child: Text("Simpan")
          // )
          
        ],
      )
    );
  }

  // --- DIALOG GANTI PASSWORD ---
  void _showChangePasswordDialog() {
    final _oldPassController = TextEditingController();
    final _newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Ganti Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _oldPassController, obscureText: true, decoration: InputDecoration(labelText: "Password Lama")),
            TextField(controller: _newPassController, obscureText: true, decoration: InputDecoration(labelText: "Password Baru")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () async {
              // String msg = await Provider.of<AuthProvider>(context, listen: false)
              //     .changePassword(_oldPassController.text, _newPassController.text);
              
              // Navigator.pop(ctx);
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            }, 
            child: Text("Simpan")
          )
        ],
      )
    );
  }

  // --- LOGOUT ---
  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Konfirmasi"),
        content: Text("Yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal")),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }, 
            child: Text("Ya, Keluar", style: TextStyle(color: Colors.red))
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user terbaru dari Provider
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER PROFIL
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: kPrimaryColor),
                  ),
                  SizedBox(height: 15),
                  Text(
                    user?.namaLengkap ?? "Penumpang", 
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  Text(
                    "NIK: ${user?.nik ?? '-'}", 
                    style: TextStyle(color: Colors.white70)
                  ),
                ],
              ),
            ),

            // 2. MENU LIST
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Kartu Info Akun
                  _buildMenuCard([
                    _buildMenuItem(Icons.edit, "Edit Data Diri", "Ubah nama, alamat, telepon", _showEditProfileDialog),
                    Divider(height: 1),
                    _buildMenuItem(Icons.lock, "Ganti Password", "Amankan akun anda", _showChangePasswordDialog),
                  ]),
                  
                  SizedBox(height: 20),
                  
                  // Kartu Bantuan & Logout
                  _buildMenuCard([
                    _buildMenuItem(Icons.help_outline, "Pusat Bantuan", "FAQ dan Hubungi Kami", () {}),
                    Divider(height: 1),
                    _buildMenuItem(Icons.info_outline, "Tentang Aplikasi", "Versi 1.0.0", () {}),
                    Divider(height: 1),
                    _buildMenuItem(Icons.logout, "Keluar", "Logout dari aplikasi", _logout, isDanger: true),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper biar kodingan rapi
  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0,2))]
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: isDanger ? Colors.red[50] : Colors.blue[50], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: isDanger ? Colors.red : kPrimaryColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDanger ? Colors.red : Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );  
  }
}