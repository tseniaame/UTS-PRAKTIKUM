import 'package:flutter/material.dart';
import '../screens/order_form_screen.dart';
import '../tabs/riwayat_tab.dart';

// Variabel Global untuk menyimpan daftar produk agar stoknya sinkron antar halaman
ValueNotifier<List<Map<String, dynamic>>> produkListNotifier = ValueNotifier([
  {
    'nama': 'Laptop Office 14 Inch',
    'hargaAsli': 6500000,
    'diskonLabel': '10% OFF',
    'stok': 8,
    'gambar': 'assets/images/laptop.jpg'
  },
  {
    'nama': 'Printer Thermal Kasir',
    'hargaAsli': 850000,
    'diskonLabel': 'Stok Hemat',
    'stok': 15,
    'gambar': 'assets/images/thermal.jpg'
  },
  {
    'nama': 'Kertas HVS A4 80gsm',
    'hargaAsli': 52000,
    'diskonLabel': 'Best Seller',
    'stok': 50,
    'gambar': 'assets/images/hvs.jpg'
  },
  {
    'nama': 'Scanner Barcode 2D',
    'hargaAsli': 320000,
    'diskonLabel': 'Item Baru',
    'stok': 20,
    'gambar': 'assets/images/scanner.jpg'
  },
  {
    'nama': 'Mouse Wireless Pro',
    'hargaAsli': 145000,
    'diskonLabel': 'Diskon 5%',
    'stok': 35,
    'gambar': 'assets/images/mouse.jpg'
  },
]);

// Fungsi helper untuk memformat angka dengan titik (contoh: 6500000 -> 6.500.000)
String formatRupiah(num angka) {
  String str = angka.toString();
  String result = '';
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    count++;
    result = str[i] + result;
    if (count % 3 == 0 && i != 0) {
      result = '.' + result;
    }
  }
  return 'Rp $result';
}

class KatalogTab extends StatelessWidget {
  const KatalogTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              labelColor: Colors.indigo,
              indicatorColor: Colors.indigo,
              tabs: [
                Tab(text: 'Daftar Produk'),
                Tab(text: 'Ketentuan Promo'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            ProdukSubTab(),
            KetentuanPromoSubTab(),
          ],
        ),
      ),
    );
  }
}

class ProdukSubTab extends StatelessWidget {
  const ProdukSubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: produkListNotifier,
      builder: (context, produkList, child) {
        return ListView.builder(
          itemCount: produkList.length,
          itemBuilder: (context, index) {
            final item = produkList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            item['gambar'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              item['diskonLabel'],
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          // Harga diformat dengan titik
                          Text(formatRupiah(item['hargaAsli']), style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600)),
                          Text('Stok: ${item['stok']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: item['stok'] > 0
                          ? () async {
                              // Membuka form pesanan sambil membawa data produk & index
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderFormScreen(produk: item, index: index),
                                ),
                              );

                              // Jika transaksi berhasil dan stok dikurangi
                              if (result != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result.toString()),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          : null, // Tombol mati jika stok habis
                      child: Text(item['stok'] > 0 ? 'Pesan' : 'Habis'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class KetentuanPromoSubTab extends StatefulWidget {
  const KetentuanPromoSubTab({super.key});

  @override
  State<KetentuanPromoSubTab> createState() => _KetentuanPromoSubTabState();
}

class _KetentuanPromoSubTabState extends State<KetentuanPromoSubTab> {
  final List<Map<String, dynamic>> _promoList = [
    {
      'title': 'Voucher Diskon Member 10%',
      'body': 'Berlaku untuk seluruh produk elektronik dengan minimal transaksi Rp 500.000.',
      'isExpanded': false
    },
    {
      'title': 'Gratis Ongkir Layanan Instan',
      'body': 'Khusus area pengiriman maksimal 10 KM dengan kurir instan toko.',
      'isExpanded': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: ExpansionPanelList(
        expansionCallback: (index, isExpanded) {
          setState(() {
            _promoList[index]['isExpanded'] = isExpanded;
          });
        },
        children: _promoList.map<ExpansionPanel>((item) {
          return ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return ListTile(
                title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
            body: ListTile(
              title: Text(item['body'], style: const TextStyle(color: Colors.black87)),
            ),
            isExpanded: item['isExpanded'],
          );
        }).toList(),
      ),
    );
  }
}