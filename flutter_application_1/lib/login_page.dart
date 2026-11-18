import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  bool lihatPassword = false;
  bool isLoading = false;
  String? pesanError;
  Future<void> login() async {
    
    if (email == '' || password == '') {
      setState(() {
        pesanError = 'Email dan password harus diisi';
      });
      return;
    }
    setState(() {
      isLoading = true;
      pesanError = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String pesan = 'Login gagal. Silakan coba kembali.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        pesan = 'Email atau password salah.';
      } else if (e.code == 'wrong-password') {
        pesan = 'Password yang dimasukkan salah.';
      } else if (e.code == 'invalid-email') {
        pesan = 'Format email tidak valid.';
      } else if (e.code == 'network-request-failed') {
        pesan = 'Tidak dapat terhubung. Periksa koneksi internet.';
      }
      if (mounted) setState(() => pesanError = pesan);
    } catch (e) {
      if (mounted) setState(() => pesanError = 'Terjadi kesalahan. Silakan coba kembali.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 30),
          const Icon(Icons.science, size: 80, color: Colors.teal),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Inventaris Lab',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            onChanged: (value) {
              email = value;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: !lihatPassword,
            onChanged: (value) {
              password = value;
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  lihatPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    lihatPassword = !lihatPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            pesanError ?? '',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 12),
          isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
            onPressed: login,
            child: const Text('Login'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
            child: const Text('Belum punya akun? Daftar'),
          ),
        ],
      ),
    );
  }
}