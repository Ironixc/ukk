import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk/screens/passenger/home_screen.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';
import 'register_screen.dart';
import '../admin/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk mengambil input text
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  
  //sembunyi password
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi Logika Login
  void _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username dan Password harus diisi!")),
      );
      return;
    }

    // Panggil Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Proses Login
    bool success = await authProvider.login(identifier, password);

    if (success) {
      // Cek Role User untuk navigasi
      final role = authProvider.currentUser?.role;

      if (mounted) {
        if (role == 'admin') {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => DashboardScreen())
          );
        } else {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => PassengerHomeScreen())
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Gagal! Cek Username/Password."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil size layar
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ------------------------------------------------
            // BAGIAN HEADER 
            // ------------------------------------------------
            Container(
              height: size.height * 0.35,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.train_rounded, size: 80, color: kSecondaryColor),
                  SizedBox(height: 15),
                  Text(
                    "KAI ACCESS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "Clone App",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------
            // BAGIAN FORM LOGIN
            // ------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat Datang!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text("Silakan masuk untuk memesan tiket.", style: TextStyle(color: Colors.grey)),
                  
                  SizedBox(height: 30),

                  // Input Username
                  TextField(
                    controller: _identifierController,
                    decoration: InputDecoration(
                      labelText: "Username / Nama Penumpang",
                      prefixIcon: Icon(Icons.person_outline, color: kPrimaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Input Password
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, // Sembunyikan text
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline, color: kPrimaryColor),
                      // show/hide
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  SizedBox(height: 40),

                  // Tombol Login
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          onPressed: auth.isLoading ? null : _handleLogin,
                          child: auth.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "MASUK SEKARANG",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Tombol ke Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Belum punya akun? "),
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke Register Screen
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => RegisterScreen())
                          );
                        },
                        child: Text(
                          "Daftar Disini",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}