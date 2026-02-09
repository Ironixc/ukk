import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _obscurePassword = true;

  // VALIDASI USERNAME
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username wajib diisi';
    }
    if (value.length < 4) {
      return 'Username minimal 4 karakter';
    }
    if (value.length > 20) {
      return 'Username maksimal 20 karakter';
    }
    // Hanya boleh huruf, angka, underscore, dan titik
    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value)) {
      return 'Username hanya boleh huruf, angka, underscore, dan titik';
    }
    return null;
  }

  // VALIDASI PASSWORD (KUAT)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (value.length > 50) {
      return 'Password maksimal 50 karakter';
    }
    // Harus ada huruf besar
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung huruf besar';
    }
    // Harus ada huruf kecil
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung huruf kecil';
    }
    // Harus ada angka
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung angka';
    }
    // Harus ada karakter spesial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password harus mengandung karakter spesial (!@#%^&*...)';
    }
    return null;
  }

  // VALIDASI NIK (16 DIGIT)
  String? _validateNIK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK wajib diisi';
    }
    // Hapus semua karakter non-digit
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length != 16) {
      return 'NIK harus tepat 16 digit';
    }
    // Validasi apakah semua karakter adalah angka
    if (!RegExp(r'^[0-9]{16}$').hasMatch(digitsOnly)) {
      return 'NIK hanya boleh berisi angka';
    }
    return null;
  }

  // VALIDASI NAMA LENGKAP
  String? _validateNama(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    if (value.length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    // Hanya boleh huruf dan spasi
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Nama hanya boleh berisi huruf dan spasi';
    }
    return null;
  }

  // VALIDASI NOMOR TELEPON
  String? _validateTelp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    // Hapus semua karakter non-digit
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }
    if (digitsOnly.length > 15) {
      return 'Nomor telepon maksimal 15 digit';
    }
    // Harus dimulai dengan 0 atau +62
    if (!value.startsWith('0') && !value.startsWith('+62') && !value.startsWith('62')) {
      return 'Nomor telepon harus dimulai dengan 0, 62, atau +62';
    }
    return null;
  }

  // VALIDASI ALAMAT
  String? _validateAlamat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat wajib diisi';
    }
    if (value.length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    if (value.length > 200) {
      return 'Alamat maksimal 200 karakter';
    }
    return null;
  }

  void _submitRegister() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon perbaiki data yang tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await Provider.of<AuthProvider>(context, listen: false).register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      nik: _nikController.text.replaceAll(RegExp(r'\D'), ''), // Kirim hanya angka
      namaPenumpang: _namaController.text.trim(),
      alamat: _alamatController.text.trim(),
      telp: _telpController.text.trim(),
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
                          
                          // USERNAME
                          _buildTextField(
                            controller: _usernameController,
                            label: "Username",
                            hint: "Minimal 4 karakter, tanpa spasi",
                            icon: Icons.account_circle_outlined,
                            validator: _validateUsername,
                          ),
                          const SizedBox(height: 15),
                          
                          // PASSWORD dengan toggle visibility
                          _buildPasswordField(),
                          
                          const SizedBox(height: 30),
                          _buildSectionTitle("Informasi Pribadi"),
                          
                          // NIK
                          _buildTextField(
                            controller: _nikController,
                            label: "NIK (KTP)",
                            hint: "16 digit nomor induk",
                            icon: Icons.assignment_ind_outlined,
                            inputType: TextInputType.number,
                            validator: _validateNIK,
                            maxLength: 16,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 15),
                          
                          // NAMA LENGKAP
                          _buildTextField(
                            controller: _namaController,
                            label: "Nama Lengkap",
                            hint: "Sesuai kartu identitas",
                            icon: Icons.person_outline,
                            validator: _validateNama,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                            ],
                          ),
                          const SizedBox(height: 15),
                          
                          // NOMOR TELEPON
                          _buildTextField(
                            controller: _telpController,
                            label: "Nomor Telepon",
                            hint: "Contoh: 081234567890",
                            icon: Icons.phone_android_outlined,
                            inputType: TextInputType.phone,
                            validator: _validateTelp,
                            maxLength: 15,
                          ),
                          const SizedBox(height: 15),
                          
                          // ALAMAT
                          _buildTextField(
                            controller: _alamatController,
                            label: "Alamat",
                            hint: "Alamat lengkap saat ini (min. 10 karakter)",
                            icon: Icons.home_outlined,
                            maxLines: 3,
                            validator: _validateAlamat,
                          ),

                          const SizedBox(height: 40),

                          // Tombol Register
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
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "DAFTAR SEKARANG",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                    Text(
                      "Sudah punya akun? ",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: kSecondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: _validatePassword,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: "Min 8 karakter, huruf besar/kecil, angka, simbol",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline, color: kPrimaryColor, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Password requirements hint
        Text(
          "• Minimal 8 karakter\n"
          "• Mengandung huruf besar & kecil\n"
          "• Mengandung angka\n"
          "• Mengandung karakter spesial (!@#\$%^&*...)",
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
        ),
      ],
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
    int? maxLength,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: inputType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: validator ?? (value) => (value == null || value.isEmpty) ? '$label wajib diisi' : null,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            counterText: '', // Hide character counter
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nikController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _telpController.dispose();
    super.dispose();
  }
}