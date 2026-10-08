import 'package:flutter/material.dart';
import '../tabs/katalog_tab.dart';
import '../tabs/riwayat_tab.dart';

class OrderFormScreen extends StatefulWidget {
  final Map<String, dynamic> produk;
  final int index;

  const OrderFormScreen({super.key, required this.produk, required this.index});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  String _metodePengiriman = 'Reguler';
  bool _asuransi = false;
  bool _bubbleWrap = false;
  bool _packingKayu = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double _diskonMember = 0.0; // Slider diskon aktif
  bool _isDropship = false;

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _prosesTransaksi() {
    num hargaAsli = widget.produk['hargaAsli'];
    num potongan = hargaAsli * (_diskonMember / 100);
    num totalHarga = hargaAsli - potongan;

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rincian Biaya Pemesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Item: ${widget.produk['nama']}'),
              Text('Harga Normal: ${formatRupiah(hargaAsli)}'),
              Text('Diskon Member (${_diskonMember.toInt()}%): - ${formatRupiah(potongan.toInt())}'),
              Text('Total Pembayaran: ${formatRupiah(totalHarga.toInt())}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              Text('Kurir: $_metodePengiriman'),
              Text('Dropship/Kado: ${_isDropship ? "Ya" : "Tidak"}'),
              const Divider(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: () {
                  showDialog(
                    context: bottomSheetContext,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Konfirmasi Transaksi'),
                      content: const Text('Apakah data pesanan sudah sesuai dan siap diproses?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            // 1. Kurangi stok produk secara nyata
                            List<Map<String, dynamic>> updatedList = List.from(produkListNotifier.value);
                            int currentStok = updatedList[widget.index]['stok'];
                            if (currentStok > 0) {
                              updatedList[widget.index]['stok'] = currentStok - 1;
                              produkListNotifier.value = updatedList;
                            }

                            // 2. Tambahkan ke Riwayat Transaksi otomatis
                            final String autoId = 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                            final String todayDate = DateTime.now().toString().substring(0, 10);
                            
                            final newTrx = {
                              'id': autoId,
                              'tanggal': todayDate,
                              'total': formatRupiah(totalHarga.toInt()),
                              'status': 'Selesai',
                            };

                            riwayatTransaksiNotifier.value = [
                              ...riwayatTransaksiNotifier.value,
                              newTrx,
                            ];

                            Navigator.pop(dialogContext); // Tutup Dialog
                            Navigator.pop(bottomSheetContext); // Tutup BottomSheet
                            Navigator.pop(context, 'Pesanan ${widget.produk['nama']} Berhasil & Stok Tersisa: ${updatedList[widget.index]['stok']}!');
                          },
                          child: const Text('Setuju'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Konfirmasi Pembayaran'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    num hargaAsli = widget.produk['hargaAsli'];
    num potongan = hargaAsli * (_diskonMember / 100);
    num totalAkhir = hargaAsli - potongan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pemesanan'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item Dipilih: ${widget.produk['nama']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Harga: ${formatRupiah(hargaAsli)}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600)),
            const Divider(height: 24),
            
            const Text('Metode Pengiriman:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Reguler'),
              value: 'Reguler',
              groupValue: _metodePengiriman,
              onChanged: (val) => setState(() => _metodePengiriman = val!),
            ),
            RadioListTile<String>(
              title: const Text('Kargo'),
              value: 'Kargo',
              groupValue: _metodePengiriman,
              onChanged: (val) => setState(() => _metodePengiriman = val!),
            ),
            RadioListTile<String>(
              title: const Text('Instan'),
              value: 'Instan',
              groupValue: _metodePengiriman,
              onChanged: (val) => setState(() => _metodePengiriman = val!),
            ),
            const SizedBox(height: 12),

            const Text('Layanan Ekstra:', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Asuransi Pengiriman'),
              value: _asuransi,
              onChanged: (val) => setState(() => _asuransi = val!),
            ),
            CheckboxListTile(
              title: const Text('Bubble Wrap Ekstra'),
              value: _bubbleWrap,
              onChanged: (val) => setState(() => _bubbleWrap = val!),
            ),
            CheckboxListTile(
              title: const Text('Packing Kayu'),
              value: _packingKayu,
              onChanged: (val) => setState(() => _packingKayu = val!),
            ),
            const SizedBox(height: 12),

            const Text('Jadwal Pengambilan:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? 'Pilih Tanggal'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime == null ? 'Pilih Jam' : _selectedTime!.format(context)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Slider Diskon Aktif
            Text('Diskon Member: ${_diskonMember.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _diskonMember,
              min: 0,
              max: 50,
              divisions: 5,
              label: '${_diskonMember.round()}%',
              onChanged: (val) => setState(() => _diskonMember = val),
            ),
            Text('Estimasi Harga Setelah Diskon: ${formatRupiah(totalAkhir.toInt())}', 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Kirim sebagai Dropship / Bungkus Kado'),
              value: _isDropship,
              onChanged: (val) => setState(() => _isDropship = val),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _prosesTransaksi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Proses Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}