
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailInventarisPage extends StatefulWidget {
  final String itemId;
  final Map<String, dynamic> data;

  const DetailInventarisPage({
    super.key,
    required this.itemId,
    required this.data,
  });

  @override
  State<DetailInventarisPage> createState() =>
      _DetailInventarisPageState();
}

class _DetailInventarisPageState
    extends State<DetailInventarisPage> {
  bool isLoading = false;

  Future<void> ajukanPinjam() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu.'),
        ),
      );
      return;
    }

    if (widget.data['status'] != 'Available') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alat sedang dipinjam dan belum tersedia.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final pinjaman = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('borrowings')
          .doc();

      await pinjaman.set({
        'borrow_id': pinjaman.id,
        'item_id': widget.itemId,
        'item_name': widget.data['item_name'] ?? '',
        'borrow_date': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pengajuan peminjaman berhasil disimpan.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pengajuan peminjaman gagal. '
              'Periksa koneksi dan izin Firestore.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final image = data['image']?.toString() ?? '';
    final tersedia = data['status'] == 'Available';

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Detail Inventaris'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: image.isEmpty
                ? Container(
                    height: 220,
                    color: Colors.teal.shade100,
                    child: const Icon(
                      Icons.science,
                      size: 90,
                      color: Colors.teal,
                    ),
                  )
                : Image.network(
                    image,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 220,
                        color: Colors.teal.shade100,
                        child: const Icon(
                          Icons.broken_image,
                          size: 70,
                          color: Colors.teal,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),

          Text(
            data['item_name'] ?? '-',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _barisDetail(
            'Kategori',
            data['category'] ?? '-',
          ),

          _barisDetail(
            'Kode serial',
            data['code'] ?? '-',
          ),

          _barisDetail(
            'Status',
            data['status'] ?? '-',
          ),

          _barisDetail(
            'Spesifikasi',
            data['spesification'] ?? '-',
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: isLoading || !tersedia
                ? null
                : ajukanPinjam,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.assignment),
            label: Text(
              tersedia
                  ? 'Ajukan Peminjaman'
                  : 'Alat Sedang Dipinjam',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barisDetail(String judul, String isi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: TextStyle(
              color: Colors.teal.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(isi),
        ],
      ),
    );
  }
}
