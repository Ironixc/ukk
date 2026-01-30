import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // GlobalKey untuk validasi Form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk menangkap input
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _telpController = TextEditingController();

  // Fungsi saat tombol Daftar ditekan
  void _submitRegister() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop jika ada form kosong
    }

    // Panggil Provider Register
    final response = await Provider.of<AuthProvider>(context, listen: false).register(
      username: _usernameController.text,
      password: _passwordController.text,
      nik: _nikController.text,
      namaPenumpang: _namaController.text,
      alamat: _alamatController.text,
      telp: _telpController.text,
    );

    // Cek Respon dari PHP
    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Kembali ke halaman Login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${response['message']}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Warna abu muda
      appBar: AppBar(
        title: Text("Daftar Akun Baru"),
        backgroundColor: kPrimaryColor, // Biru KAI
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Dekorasi
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.person_add, size: 50, color: kSecondaryColor),
                    SizedBox(width: 15),
                    Text(
                      "Bergabung bersama\nKAI Access",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSectionTitle("Data Akun"),
                    _buildTextField(
                      controller: _usernameController,
                      label: "Username",
                      icon: Icons.account_circle,
                    ),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),

                    SizedBox(height: 25),
                    _buildSectionTitle("Data Pribadi"),
                    _buildTextField(
                      controller: _nikController,
                      label: "Nomor Induk Kependudukan (NIK)",
                      icon: Icons.card_membership,
                      inputType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller: _namaController,
                      label: "Nama Lengkap (Sesuai KTP)",
                      icon: Icons.badge,
                    ),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller: _telpController,
                      label: "Nomor Telepon",
                      icon: Icons.phone,
                      inputType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller: _alamatController,
                      label: "Alamat Lengkap",
                      icon: Icons.home,
                      maxLines: 2,
                    ),

                    SizedBox(height: 30),
                    
                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondaryColor, // Oranye
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _submitRegister,
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, _) => auth.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk membuat Input Field lebih rapi
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kPrimaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}