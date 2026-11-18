import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Pengguna belum login.')));
    }

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat profil.'));
          }

          final data = snapshot.data?.data() ?? {};

          final nama =
              data['name']?.toString() ?? user.displayName ?? 'Nama siswa';

          final kelas = data['kelas']?.toString() ?? '-';

          final email = data['email']?.toString() ?? user.email ?? '-';

          final foto = data['foto']?.toString() ?? '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // KARTU PROFIL
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.teal.shade100,
                      backgroundImage: foto.isNotEmpty
                          ? NetworkImage(foto)
                          : null,
                      child: foto.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.teal,
                            )
                          : null,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Kelas $kelas',
                      style: TextStyle(color: Colors.teal.shade700),
                    ),

                    const SizedBox(height: 4),

                    Text(email, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // RIWAYAT PEMINJAMAN
              const Text(
                'Riwayat Peminjaman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('borrowings')
                    .orderBy('borrow_date', descending: true)
                    .snapshots(),
                builder: (context, riwayat) {
                  if (riwayat.hasError) {
                    return const Text('Gagal memuat riwayat peminjaman.');
                  }

                  if (riwayat.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final daftar = riwayat.data?.docs ?? [];

                  if (daftar.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Belum ada riwayat peminjaman.'),
                      ),
                    );
                  }

                  return Column(
                    children: daftar.map((doc) {
                      final item = doc.data();
                      final tanggal = item['borrow_date'];

                      String tanggalTeks = '-';

                      if (tanggal is Timestamp) {
                        final date = tanggal.toDate();

                        tanggalTeks =
                            '${date.day.toString().padLeft(2, '0')}/'
                            '${date.month.toString().padLeft(2, '0')}/'
                            '${date.year}';
                      }

                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: const Icon(
                              Icons.science,
                              color: Colors.teal,
                            ),
                          ),
                          title: Text(item['item_name']?.toString() ?? '-'),
                          subtitle: Text('Tanggal pinjam: $tanggalTeks'),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
