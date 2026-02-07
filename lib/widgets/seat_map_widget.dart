import 'package:flutter/material.dart';

class SeatMapWidget extends StatefulWidget {
  final List<dynamic> allSeats;         
  final List<String> occupiedSeats;     
  final List<String> selectedSeats;     
  final int passengerCount;             
  final Function(List<String>) onSeatSelected; 

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
    // asumsikan layout kereta adalah 2-2 (A B - C D)
    // Jadi setiap 4 kursi akan membentuk 1 baris baru
    int totalRows = (widget.allSeats.length / 4).ceil();

    return Column(
      children: [
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

        // 3. GRID KURSI
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
                    
                    // NOMOR BARIS 
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

  // WIDGET 
  Widget _buildSeatItem(int index) {
    // Cek validasi index data kursi
    if (index >= widget.allSeats.length) {
      return Container(width: 45, height: 45, margin: EdgeInsets.symmetric(horizontal: 4)); // Kotak kosong
    }

    final seat = widget.allSeats[index];
    String seatId = seat['id'].toString();
    
    bool isOccupied = widget.occupiedSeats.contains(seatId); 
    bool isSelected = widget.selectedSeats.contains(seatId);
    
    Color boxColor = Colors.grey[200]!;     // Default
    Color borderColor = Colors.grey[400]!;
    
    if (isOccupied) {
      boxColor = Colors.orange[800]!;       
      borderColor = Colors.orange[900]!;
    } else if (isSelected) {
      boxColor = Colors.blue;               
      borderColor = Colors.blueAccent;
    }

    return GestureDetector(
      onTap: () {
        if (isOccupied) return; // Tidak bisa pilih kursi terisi

        List<String> newSelection = List.from(widget.selectedSeats);

        if (isSelected) {
          newSelection.remove(seatId);
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
            ? Icon(Icons.close, color: Colors.white70, size: 20) 
            : Text(
                _getSeatLetter(index), // Huruf Kursi
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600], 
                  fontWeight: FontWeight.bold
                ),
              ),
        ),
      ),
    );
  }

  // (A, B, C, D)
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