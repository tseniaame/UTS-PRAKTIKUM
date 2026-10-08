import 'package:flutter/material.dart';

// Variabel global agar bisa menerima data dari halaman Katalog
final ValueNotifier<List<Map<String, dynamic>>> riwayatTransaksiNotifier = ValueNotifier([]);

class RiwayatTab extends StatelessWidget {
  const RiwayatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: riwayatTransaksiNotifier,
      builder: (context, riwayatList, child) {
        
        // Jika belum ada pesanan, tampilkan teks kosong
        if (riwayatList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada riwayat transaksi.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Jika ada pesanan, tampilkan dalam bentuk tabel
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID Transaksi', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: riwayatList.map((trx) {
                return DataRow(cells: [
                  DataCell(Text(trx['id'])),
                  DataCell(Text(trx['tanggal'])),
                  DataCell(Text(trx['total'])),
                  DataCell(
                    Text(
                      trx['status'],
                      style: TextStyle(
                        color: trx['status'] == 'Selesai' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}