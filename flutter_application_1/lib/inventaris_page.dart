
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detail_inventaris_page.dart';

class InventarisPage extends StatelessWidget {
  const InventarisPage({super.key});

  Future<void> _formInventaris(
    BuildContext context, {
    String? itemId,
    Map<String, dynamic>? data,
  }) async {
    final pageContext = context;

    final namaController =
        TextEditingController(text: data?['item_name'] ?? '');
    final kategoriController =
        TextEditingController(text: data?['category'] ?? '');
    final kodeController =
        TextEditingController(text: data?['code'] ?? '');
    final gambarController =
        TextEditingController(text: data?['image'] ?? '');
    final spesifikasiController =
        TextEditingController(text: data?['spesification'] ?? '');

    String status = data?['status'] ?? 'Available';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContextInner, ubahDialog) => AlertDialog(
          title: Text(
            itemId == null ? 'Tambah Inventaris' : 'Edit Inventaris',
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _input(namaController, 'Nama alat'),
                  _input(kategoriController, 'Kategori'),
                  _input(kodeController, 'Kode serial'),
                  _input(gambarController, 'URL gambar'),
                  _input(
                    spesifikasiController,
                    'Spesifikasi',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'Borrowed',
                        child: Text('Borrowed'),
                      ),
                    ],
                    onChanged: (value) {
                      ubahDialog(() {
                        status = value ?? 'Available';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final koleksi =
                    FirebaseFirestore.instance.collection('items');

                final dataItem = <String, dynamic>{
                  'item_name': namaController.text.trim(),
                  'category': kategoriController.text.trim(),
                  'code': kodeController.text.trim(),
                  'status': status,
                  'image': gambarController.text.trim(),
                  'spesification':
                      spesifikasiController.text.trim(),
                };

                try {
                  if (itemId == null) {
                    final doc = koleksi.doc();

                    dataItem['item_id'] = doc.id;
                    dataItem['created_at'] =
                        FieldValue.serverTimestamp();

                    await doc.set(dataItem);
                  } else {
                    await koleksi.doc(itemId).update(dataItem);
                  }

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (pageContext.mounted) {
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          itemId == null
                              ? 'Inventaris ditambahkan.'
                              : 'Inventaris diperbarui.',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (pageContext.mounted) {
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Gagal menyimpan data inventaris. '
                          'Periksa koneksi dan izin Firestore.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    namaController.dispose();
    kategoriController.dispose();
    kodeController.dispose();
    gambarController.dispose();
    spesifikasiController.dispose();
  }

  static Widget _input(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label harus diisi';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _hapus(
    BuildContext context,
    String itemId,
    String nama,
  ) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Inventaris?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "$nama"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      try {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(itemId)
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inventaris berhasil dihapus.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus inventaris.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Inventaris'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () => _formInventaris(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .orderBy('item_name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal memuat data inventaris.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final dokumen = snapshot.data?.docs ?? [];

          if (dokumen.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data inventaris. Tekan + untuk menambahkan.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dokumen.length,
            itemBuilder: (context, index) {
              final doc = dokumen[index];
              final data = doc.data();

              final nama = data['item_name'] ?? 'Tanpa nama';
              final image = data['image'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image.toString().isNotEmpty
                        ? Image.network(
                            image,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _gambarKosong(),
                          )
                        : _gambarKosong(),
                  ),
                  title: Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${data['category'] ?? '-'}\n'
                    '${data['code'] ?? '-'}',
                    maxLines: 2,
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailInventarisPage(
                          itemId: doc.id,
                          data: data,
                        ),
                      ),
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _formInventaris(
                          context,
                          itemId: doc.id,
                          data: data,
                        );
                      }

                      if (value == 'hapus') {
                        _hapus(context, doc.id, nama);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'hapus',
                        child: Text('Hapus'),
                      ),
                    ],
                  ),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _gambarKosong() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.teal.shade100,
      child: const Icon(
        Icons.science,
        color: Colors.teal,
        size: 30,
      ),
    );
  }
}
