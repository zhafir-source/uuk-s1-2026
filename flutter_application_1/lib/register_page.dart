import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String nama = '';
  String kelas = '';
  String email = '';
  String password = '';
  bool lihatPassword = false;
  bool isLoading = false;
  String? pesanError;

  Future<void> register() async {
    if (nama.trim().isEmpty || kelas.trim().isEmpty ||
        email.trim().isEmpty || password.isEmpty) {
      setState(() => pesanError = 'Semua kolom harus diisi.');
      return;
    }
    if (password.length < 6) {
      setState(() => pesanError = 'Password minimal 6 karakter.');
      return;
    }

    setState(() {
      isLoading = true;
      pesanError = null;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final hasil = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        user = hasil.user;
      }

      if (user == null) {
        throw Exception('Akun tidak berhasil dibuat.');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'user_id': user.uid,
        'name': nama.trim(),
        'email': email.trim(),
        'kelas': kelas.trim(),
        'created_at': FieldValue.serverTimestamp(),
        'foto': '',
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String pesan = 'Registrasi gagal. Silakan coba kembali.';
      if (e.code == 'email-already-in-use') {
        pesan = 'Email sudah terdaftar. Silakan login menggunakan email tersebut.';
      } else if (e.code == 'invalid-email') {
        pesan = 'Format email tidak valid.';
      } else if (e.code == 'weak-password') {
        pesan = 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      } else if (e.code == 'network-request-failed') {
        pesan = 'Tidak dapat terhubung. Periksa koneksi internet.';
      }
      if (mounted) setState(() => pesanError = pesan);
    } catch (e) {
      if (mounted) {
        setState(() => pesanError =
            'Akun berhasil dibuat, tetapi data profil belum tersimpan. Tekan Daftar kembali untuk mencoba menyimpan profil.');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          const Icon(Icons.science, size: 70, color: Colors.teal),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => nama = value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Nama',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => kelas = value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Kelas',
              prefixIcon: Icon(Icons.school),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: !lihatPassword,
            onChanged: (value) => password = value,
            decoration: InputDecoration(
              border: const OutlineInputBorder(), labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(lihatPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => lihatPassword = !lihatPassword),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (pesanError != null)
            Text(pesanError!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading ? null : register,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Daftar'),
          ),
        ],
      ),
    );
  }
}
