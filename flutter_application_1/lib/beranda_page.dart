
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detail_inventaris_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  String kataCari = '';
  int bannerIndex = 0;

  final List<Map<String, String>> banner = [
    {
      'judul': 'Peralatan Laboratorium',
      'deskripsi': 'Kelola inventaris alat laboratorium.',
      'gambar': 'assets/images/gelas.png',
    },
    {
      'judul': 'Peralatan Elektronik',
      'deskripsi': 'Temukan peralatan elektronik laboratorium.',
      'gambar': 'assets/images/elektronik.png',
    },
    {
      'judul': 'Alat Optik',
      'deskripsi': 'Lihat koleksi peralatan optik.',
      'gambar': 'assets/images/optik.png',
    },
  ];

  void gantiBanner(int arah) {
    setState(() {
      bannerIndex = (bannerIndex + arah) % banner.length;
      if (bannerIndex < 0) {
        bannerIndex = banner.length - 1;
      }
    });
  }

  Widget judulBagian(String teks) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            teks,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget gambarBarang(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.teal.shade50,
        child: const Icon(
          Icons.science_outlined,
          color: Colors.teal,
          size: 32,
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.teal.shade50,
          child: const Icon(
            Icons.science_outlined,
            color: Colors.teal,
            size: 32,
          ),
        );
      },
    );
  }

  void bukaDetail(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailInventarisPage(
          itemId: doc.id,
          data: doc.data(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Beranda',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // PENCARIAN
          TextField(
            onChanged: (value) {
              setState(() {
                kataCari = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari alat inventaris',
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.teal,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // BANNER
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < 0) gantiBanner(1);
              if (velocity > 0) gantiBanner(-1);
            },
            child: Container(
              height: 145,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner[bannerIndex]['judul']!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banner[bannerIndex]['deskripsi']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      banner[bannerIndex]['gambar']!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.science_outlined,
                          size: 65,
                          color: Colors.teal,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => gantiBanner(-1),
                icon: const Icon(Icons.chevron_left, color: Colors.teal),
              ),
              Text(
                '${bannerIndex + 1} / ${banner.length}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              IconButton(
                onPressed: () => gantiBanner(1),
                icon: const Icon(Icons.chevron_right, color: Colors.teal),
              ),
            ],
          ),

          // DATA FIRESTORE
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('items')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Gagal memuat inventaris dari Firestore.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final items = snapshot.data?.docs ?? [];

              final hasilCari = items.where((doc) {
                final nama = (doc.data()['item_name'] ?? '')
                    .toString()
                    .toLowerCase();
                return nama.contains(kataCari.toLowerCase());
              }).toList();

              final kategori = <String>{};
              final statuses = <String>{};

              for (final doc in items) {
                final data = doc.data();
                final category = data['category']?.toString() ?? '';
                final status = data['status']?.toString() ?? '';

                if (category.isNotEmpty) kategori.add(category);
                if (status.isNotEmpty) statuses.add(status);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEMUA DATA
                  judulBagian('Semua Data'),

                  if (hasilCari.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('Tidak ada inventaris ditemukan.'),
                      ),
                    )
                  else
                    SizedBox(
                      height: 145,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hasilCari.length,
                        itemBuilder: (context, index) {
                          final doc = hasilCari[index];
                          final data = doc.data();

                          return GestureDetector(
                            onTap: () => bukaDetail(context, doc),
                            child: Container(
                              width: 135,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: gambarBarang(
                                          data['image']?.toString() ?? '',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      data['item_name']?.toString() ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // KATEGORI
                  judulBagian('Kategori Peralatan'),

                  if (kategori.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('Belum ada kategori.')),
                    )
                  else
                    SizedBox(
                      height: 115,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: kategori.map((nama) {
                          final itemKategori = items.where(
                            (doc) => doc.data()['category'] == nama,
                          ).toList();

                          final gambar = itemKategori.isNotEmpty
                              ? itemKategori.first.data()['image']?.toString() ??
                                  ''
                              : '';

                          return Container(
                            width: 112,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: gambarBarang(gambar),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // STATUS
                  judulBagian('Status'),

                  if (statuses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('Belum ada status.')),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: statuses.map((status) {
                        final tersedia = status == 'Available';

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: tersedia
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tersedia
                                  ? Colors.green.shade200
                                  : Colors.orange.shade200,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 13,
                              color: tersedia
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
