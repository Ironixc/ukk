import 'dart:typed_data'; // Wajib ada untuk Uint8List
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../constants.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map data;

  TicketDetailScreen({required this.data});

  // ---------------------------------------------------------------------------
  // 1. FUNGSI GENERATE PDF (HANYA MEMBUAT DATANYA)
  // ---------------------------------------------------------------------------
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final doc = pw.Document();

    // Format Tanggal
    DateTime tglBerangkat = DateTime.parse(data['tanggal_berangkat']);
    String tglStr = DateFormat('dd MMM yyyy, HH:mm').format(tglBerangkat);
    List passengers = data['detail_penumpang'];

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("E-TICKET KERETA API", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text("ORDER ID: ${data['id_pembelian']}", style: pw.TextStyle(color: PdfColors.grey)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // INFO PERJALANAN
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text(data['nama_kereta'], style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text(data['kelas']),
                      pw.SizedBox(height: 10),
                      pw.Text("Berangkat: ${data['asal_keberangkatan']}"),
                      pw.Text(tglStr, style: pw.TextStyle(fontSize: 10)),
                    ]),
                    pw.Column(children: [pw.Text("-->", style: pw.TextStyle(fontSize: 20))]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                      pw.Text("Tujuan: ${data['tujuan_keberangkatan']}"),
                      pw.Text(data['tanggal_kedatangan'], style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 10),
                      pw.Text("Total: Rp ${data['total_harga']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ]),
                  ]
                )
              ),
              
              pw.SizedBox(height: 20),
              pw.Text("Detail Penumpang", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),

              // TABEL
              pw.Table.fromTextArray(
                headers: ['No', 'Nama Penumpang', 'NIK', 'Kursi'],
                data: List<List<dynamic>>.generate(passengers.length, (index) {
                  var p = passengers[index];
                  return [(index + 1).toString(), p['nama_penumpang'], p['nik'], p['no_kursi']];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignments: {0: pw.Alignment.center, 3: pw.Alignment.center}
              ),

              pw.SizedBox(height: 50),

              // QR CODE
              pw.Center(
                child: pw.Column(children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: data['id_pembelian'].toString(),
                    width: 100, height: 100,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text("Scan saat boarding.", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ])
              )
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  // ---------------------------------------------------------------------------
  // 2. FUNGSI ACTION (TOMBOL)
  // ---------------------------------------------------------------------------
  
  // A. Logika Share (Kirim ke WA/Email)
  void _sharePdf() async {
    await Printing.sharePdf(
      bytes: await _generatePdf(PdfPageFormat.a4),
      filename: 'Tiket-${data['id_pembelian']}.pdf',
    );
  }

  // B. Logika Print (Simpan PDF / Cetak Fisik)
  void _printPdf() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _generatePdf(format),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    List penumpang = data['detail_penumpang'];

    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(title: Text("Detail Tiket"), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      
      // HAPUS FLOATING ACTION BUTTON BIASA
      // KITA GANTI TOMBOLNYA DI DALAM BODY AGAR LEBIH RAPI
      
      body: Column(
        children: [
          // BAGIAN TIKET (SCROLLABLE)
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    // ... (Tampilan Visual Tiket Sama Seperti Sebelumnya) ...
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(data['nama_kereta'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(data['kelas'], style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text("Berangkat", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(data['asal_keberangkatan'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(data['tanggal_berangkat'], style: TextStyle(fontSize: 12)),
                              ]),
                              Icon(Icons.train, color: kPrimaryColor),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text("Tiba", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(data['tujuan_keberangkatan'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(data['tanggal_kedatangan'], style: TextStyle(fontSize: 12)),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 2, color: Colors.grey[300]),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Detail Penumpang", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
                            itemCount: penumpang.length,
                            itemBuilder: (ctx, i) {
                              var p = penumpang[i];
                              return Container(
                                margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(p['nama_penumpang'], style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text("NIK: ${p['nik']}", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ]),
                                  Text("Kursi: ${p['no_kursi']}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900])),
                                ]),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    // ... QR Code area ...
                     Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
                      child: Column(children: [
                        Icon(Icons.qr_code_2, size: 80),
                        SizedBox(height: 5),
                        Text("ID: ${data['id_pembelian']}", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ]),
                    )
                  ],
                ),
              ),
            ),
          ),

          // AREA TOMBOL AKSI (DI BAWAH)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(
              children: [
                // TOMBOL 1: KIRIM / SHARE
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sharePdf,
                    icon: Icon(Icons.share, color: kPrimaryColor),
                    label: Text("KIRIM WA"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: kPrimaryColor),
                      foregroundColor: kPrimaryColor
                    ),
                  ),
                ),
                SizedBox(width: 15),
                // TOMBOL 2: CETAK / SIMPAN
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _printPdf,
                    icon: Icon(Icons.print),
                    label: Text("CETAK / PDF"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: kSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}