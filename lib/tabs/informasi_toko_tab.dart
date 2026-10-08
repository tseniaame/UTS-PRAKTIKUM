import 'package:flutter/material.dart';

class InformasiTokoTab extends StatelessWidget {
  const InformasiTokoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Profil Toko', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          SelectableText(
            'SmartRetail Official Store\nJl. Raya Subang No. 45, Jawa Barat\nKontak: support@smartretail.co.id',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          Divider(height: 32),
          Text('Kode Lisensi Resmi App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          SelectableText(
            'SR-POS-2026-NIM-GANJIL-10602058-OK',
            style: TextStyle(fontSize: 14, fontFamily: 'monospace', color: Colors.indigo),
          ),
        ],
      ),
    );
  }
}