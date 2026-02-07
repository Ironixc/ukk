import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../constants.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map data;

  TicketDetailScreen({required this.data});

  // ===========================================================================
  // 1. GENERATE PDF (LENGKAP DENGAN TANGGAL & RUTE)
  // ===========================================================================
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final doc = pw.Document();
    
    // Parsing Data Tanggal
    DateTime tgl = DateTime.parse(data['tanggal_berangkat']);
    DateTime tglTiba = DateTime.parse(data['tanggal_kedatangan']);
    
    String hariTanggal = DateFormat('EEEE, d MMMM yyyy').format(tgl);
    String jamBerangkat = DateFormat('HH:mm').format(tgl);
    String jamTiba = DateFormat('HH:mm').format(tglTiba);
    
    List passengers = data['detail_penumpang'];

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Header(level: 0, child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("E-TIKET KERETA API", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text("PT KERETA API INDONESIA", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ]
              )),
              pw.SizedBox(height: 10),

              // KODE BOOKING
              pw.Text("KODE BOOKING / BOOKING CODE", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.Text(data['id_pembelian'].toString(), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
              pw.SizedBox(height: 20),

              // --- BAGIAN BARU: DETAIL PERJALANAN (TANGGAL & RUTE) ---
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4)
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(data['nama_kereta'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.Text(data['kelas'], style: pw.TextStyle(fontSize: 12)),
                      ]
                    ),
                    pw.Divider(color: PdfColors.grey300),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        // BERANGKAT
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("Berangkat / Departure", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                            pw.Text(hariTanggal, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            pw.Text(jamBerangkat, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                            pw.Text(data['asal_keberangkatan']),
                          ]
                        ),
                        // PANAH
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 20),
                          child: pw.Icon(pw.IconData(0xe5c8), color: PdfColors.grey, size: 20),
                        ),
                        // TIBA
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text("Tiba / Arrival", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                            pw.Text(DateFormat('EEEE, d MMMM yyyy').format(tglTiba), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            pw.Text(jamTiba, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                            pw.Text(data['tujuan_keberangkatan']),
                          ]
                        ),
                      ]
                    )
                  ]
                )
              ),
              // ---------------------------------------------------------

              pw.SizedBox(height: 20),

              // TABEL PENUMPANG
              pw.Text("Detail Penumpang", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                headers: ['No', 'Nama Penumpang', 'No Identitas', 'Gerbong', 'Kursi'],
                data: List<List<dynamic>>.generate(passengers.length, (index) {
                  var p = passengers[index];
                  String gerbong = p['nama_gerbong'] ?? data['kelas'];
                  return [(index + 1).toString(), p['nama_penumpang'], p['nik'], gerbong, p['no_kursi']];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
                cellAlignments: {
                  0: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
                cellStyle: pw.TextStyle(fontSize: 10),
              ),

              pw.Spacer(),
              
              // QR CODE & FOOTER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                       pw.Text("PENTING:", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                       pw.Text("1. Tunjukkan e-tiket dan identitas asli saat boarding.", style: pw.TextStyle(fontSize: 8)),
                       pw.Text("2. Check-in dapat dilakukan mulai 7x24 jam sebelum keberangkatan.", style: pw.TextStyle(fontSize: 8)),
                    ]
                  ),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(), 
                    data: data['id_pembelian'].toString(), 
                    width: 80, height: 80
                  ),
                ]
              )
            ],
          );
        },
      ),
    );
    return doc.save();
  }

  // ===========================================================================
  // 2. UI E-BOARDING PASS (TETAP SAMA SEPERTI SEBELUMNYA)
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    List penumpang = data['detail_penumpang'];
    DateTime tgl = DateTime.parse(data['tanggal_berangkat']);
    
    return Scaffold(
      backgroundColor: kPrimaryColor, 
      appBar: AppBar(
        title: Text("E-Boarding Pass"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          children: [
            // KARTU UTAMA
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // HEADER KODE BOOKING
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                    ),
                    child: Column(
                      children: [
                        Text("KODE PEMESANAN", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.5)),
                        SizedBox(height: 5),
                        Text(
                          data['id_pembelian'].toString(), 
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kSecondaryColor, letterSpacing: 2)
                        ),
                      ],
                    ),
                  ),

                  // BODY TIKET
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // RUTE & JAM
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(data['asal_keberangkatan'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(DateFormat('dd MMM yyyy').format(tgl), style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(DateFormat('HH:mm').format(tgl) + " WIB", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                            ]),
                            Icon(Icons.arrow_forward, color: Colors.grey[300]),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(data['tujuan_keberangkatan'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text("Tiba", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(data['tanggal_kedatangan'].toString().split(' ')[1].substring(0,5) + " WIB", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                            ]),
                          ],
                        ),
                        Divider(height: 30),

                        // NAMA KERETA
                        Row(
                          children: [
                            Icon(Icons.train, color: Colors.grey),
                            SizedBox(width: 10),
                            Text(data['nama_kereta'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Spacer(),
                            Text(data['kelas'], style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Divider(height: 30),

                        // DAFTAR PENUMPANG (LEBIH JELAS)
                        Align(alignment: Alignment.centerLeft, child: Text("Daftar Penumpang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                        SizedBox(height: 10),
                        
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: penumpang.length,
                          itemBuilder: (ctx, i) {
                            var p = penumpang[i];
                            String infoGerbong = p['nama_gerbong'] ?? "${data['kelas']} 1";
                            String infoKursi = "${p['no_kursi']}";

                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // NAMA
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Nama Penumpang", style: TextStyle(fontSize: 9, color: Colors.grey)),
                                        Text(p['nama_penumpang'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text(p['nik'], style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  // GERBONG & KURSI
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text("Gerbong", style: TextStyle(fontSize: 9, color: Colors.grey)),
                                          Text(infoGerbong, style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: 13)),
                                        ],
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(color: kSecondaryColor, borderRadius: BorderRadius.circular(8)),
                                        child: Column(
                                          children: [
                                            Text("Kursi", style: TextStyle(fontSize: 8, color: Colors.white)),
                                            Text(infoKursi, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: 20),
                        // QR CODE
                        Column(
                          children: [
                            Text("Scan QR code ini saat boarding", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.qr_code_2, size: 100),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // TOMBOL SHARE / PRINT
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor, padding: EdgeInsets.symmetric(vertical: 15)),
                    onPressed: () async {
                       await Printing.layoutPdf(onLayout: (format) async => _generatePdf(format));
                    },
                    icon: Icon(Icons.print),
                    label: Text("Cetak / Simpan PDF"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}