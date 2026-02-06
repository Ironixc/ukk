import 'package:flutter/material.dart';

class SeatMapWidget extends StatefulWidget {
  final List<dynamic> allSeats;         // Semua data kursi (untuk digambar)
  final List<String> occupiedSeats;     // ID kursi yang SUDAH DIBELI orang lain
  final List<String> selectedSeats;     // ID kursi yang SAYA PILIH sekarang
  final int passengerCount;             // Jumlah penumpang (batas max pilih)
  final Function(List<String>) onSeatSelected; // Callback ke halaman booking

  const SeatMapWidget({
    Key? key,
    required this.allSeats,
    required this.occupiedSeats,
    required this.selectedSeats,
    required this.passengerCount,
    required this.onSeatSelected,
  }) : super(key: key);

  @override
  _SeatMapWidgetState createState() => _SeatMapWidgetState();
}

class _SeatMapWidgetState extends State<SeatMapWidget> {
  @override
  Widget build(BuildContext context) {
    // Kita asumsikan layout kereta adalah 2-2 (A B - C D)
    // Jadi setiap 4 kursi akan membentuk 1 baris baru
    int totalRows = (widget.allSeats.length / 4).ceil();

    return Column(
      children: [
        // 1. LEGEND (KETERANGAN WARNA)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegend(Colors.grey[200]!, "Tersedia", Colors.grey),
            _buildLegend(Colors.orange[800]!, "Terisi", Colors.white),
            _buildLegend(Colors.blue, "Dipilih", Colors.white),
          ],
        ),
        SizedBox(height: 20),

        // 2. HEADER KOLOM (A B - C D)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLabel("A"),
            _buildLabel("B"),
            SizedBox(width: 40), // Lorong Jalan
            _buildLabel("C"),
            _buildLabel("D"),
          ],
        ),
        SizedBox(height: 10),

        // 3. GRID KURSI (SCROLLABLE)
        Expanded(
          child: ListView.builder(
            itemCount: totalRows,
            itemBuilder: (context, rowIndex) {
              // Hitung index data kursi untuk baris ini
              // Baris 0 mengambil data index 0,1,2,3
              // Baris 1 mengambil data index 4,5,6,7
              int startIdx = rowIndex * 4;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SISI KIRI (A & B)
                    _buildSeatItem(startIdx),     // A
                    _buildSeatItem(startIdx + 1), // B
                    
                    // NOMOR BARIS (LORONG)
                    Container(
                      width: 40,
                      child: Center(
                        child: Text(
                          "${rowIndex + 1}", 
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
                        )
                      ),
                    ),

                    // SISI KANAN (C & D)
                    _buildSeatItem(startIdx + 2), // C
                    _buildSeatItem(startIdx + 3), // D
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // WIDGET KOTAK SATU KURSI
  Widget _buildSeatItem(int index) {
    // Cek validasi index (jika kursi ganjil/sisa)
    if (index >= widget.allSeats.length) {
      return Container(width: 45, height: 45, margin: EdgeInsets.symmetric(horizontal: 4)); // Kotak kosong
    }

    final seat = widget.allSeats[index];
    String seatId = seat['id'].toString();
    
    // Tentukan Status & Warna
    bool isOccupied = widget.occupiedSeats.contains(seatId); 
    bool isSelected = widget.selectedSeats.contains(seatId);
    
    Color boxColor = Colors.grey[200]!;     // Default
    Color borderColor = Colors.grey[400]!;
    
    if (isOccupied) {
      boxColor = Colors.orange[800]!;       // Terisi (Orange Gelap)
      borderColor = Colors.orange[900]!;
    } else if (isSelected) {
      boxColor = Colors.blue;               // Dipilih (Biru)
      borderColor = Colors.blueAccent;
    }

    return GestureDetector(
      onTap: () {
        if (isOccupied) return; // Dilarang pilih kursi orang

        List<String> newSelection = List.from(widget.selectedSeats);

        if (isSelected) {
          newSelection.remove(seatId); // Unselect
        } else {
          // Select (Cek Kuota)
          if (newSelection.length < widget.passengerCount) {
            newSelection.add(seatId);
          } else {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Maksimal ${widget.passengerCount} kursi sesuai jumlah penumpang.")));
          }
        }
        widget.onSeatSelected(newSelection);
      },
      child: Container(
        width: 45,
        height: 45,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
          boxShadow: isSelected || isOccupied ? [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0,2))] : [],
        ),
        child: Center(
          child: isOccupied 
            ? Icon(Icons.close, color: Colors.white70, size: 20) // Tanda Silang jika terisi
            : Text(
                _getSeatLetter(index), // Tampilkan A/B/C/D (Opsional)
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600], 
                  fontWeight: FontWeight.bold
                ),
              ),
        ),
      ),
    );
  }

  // Helper Huruf (A, B, C, D)
  String _getSeatLetter(int index) {
    int mod = index % 4;
    if (mod == 0) return "A";
    if (mod == 1) return "B";
    if (mod == 2) return "C";
    return "D";
  }

  Widget _buildLegend(Color color, String text, Color textColor) {
    return Row(
      children: [
        Container(
          width: 20, height: 20, 
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black12))
        ),
        SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 12))
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      width: 45, margin: EdgeInsets.symmetric(horizontal: 4),
      child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
    );
  }
}