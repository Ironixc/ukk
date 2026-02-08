import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _telpController = TextEditingController();

  void _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await Provider.of<AuthProvider>(context, listen: false).register(
      username: _usernameController.text,
      password: _passwordController.text,
      nik: _nikController.text,
      namaPenumpang: _namaController.text,
      alamat: _alamatController.text,
      telp: _telpController.text,
    );

    if (response['status'] == 'success') {
      _showSnackBar("Registrasi Berhasil! Silakan Login.", Colors.green);
      Navigator.pop(context);
    } else {
      _showSnackBar("Gagal: ${response['message']}", Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // 1. Navy Blue Header
          Container(
            height: size.height * 0.3,
            width: double.infinity,
            color: kPrimaryColor,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PERBAIKAN: Tombol Back sekarang Putih
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          // PERBAIKAN: Judul sekarang Putih
                          const Text(
                            "Daftar Akun Baru",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Lengkapi data diri Anda untuk menikmati layanan KAI",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Form Card
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Informasi Akun"),
                          _buildTextField(
                            controller: _usernameController,
                            label: "Username",
                            hint: "Buat username unik",
                            icon: Icons.account_circle_outlined,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _passwordController,
                            label: "Password",
                            hint: "Gunakan minimal 6 karakter",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          
                          const SizedBox(height: 30),
                          _buildSectionTitle("Informasi Pribadi"),
                          _buildTextField(
                            controller: _nikController,
                            label: "NIK (KTP)",
                            hint: "16 digit nomor induk",
                            icon: Icons.assignment_ind_outlined,
                            inputType: TextInputType.number,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _namaController,
                            label: "Nama Lengkap",
                            hint: "Sesuai kartu identitas",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _telpController,
                            label: "Nomor Telepon",
                            hint: "Contoh: 0812345xxx",
                            icon: Icons.phone_android_outlined,
                            inputType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _alamatController,
                            label: "Alamat",
                            hint: "Alamat lengkap saat ini",
                            icon: Icons.home_outlined,
                            maxLines: 2,
                          ),

                          const SizedBox(height: 40),

                          // Tombol Orange khas KAI
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSecondaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _submitRegister,
                              child: Consumer<AuthProvider>(
                                builder: (context, auth, _) => auth.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        "DAFTAR SEKARANG",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey.shade700)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: inputType,
          maxLines: maxLines,
          validator: (value) => (value == null || value.isEmpty) ? '$label wajib diisi' : null,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}