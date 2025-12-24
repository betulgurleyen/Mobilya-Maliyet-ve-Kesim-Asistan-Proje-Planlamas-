import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import 'optimize_screen.dart';

class CuttingListScreen extends StatelessWidget {
  const CuttingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kesim Tablosu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OptimizeScreen())),
            tooltip: "Optimize Plana Git",
          )
        ],
      ),
      body: Column(
        children: [
          // Üst Bar: Filtreler ve Dışa Aktar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blueGrey[50],
            child: Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: true, 
                    onChanged: (val) {}, 
                    title: const Text("Kapaklar Dahil", style: TextStyle(fontSize: 14)),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.red), onPressed: () {}),
                IconButton(icon: const Icon(Icons.table_view, color: Colors.green), onPressed: () {}),
              ],
            ),
          ),
          
          // Tablo
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.blueGrey[100]),
                  columns: const [
                    DataColumn(label: Text("Parça Türü")),
                    // HATA BURADAYDI: Parantezlerin yeri düzeltildi
                    DataColumn(label: Text("Adet"), numeric: true),
                    DataColumn(label: Text("En (cm)"), numeric: true),
                    DataColumn(label: Text("Boy (cm)"), numeric: true),
                    DataColumn(label: Text("Malzeme")),
                    DataColumn(label: Text("Alan (m²)"), numeric: true),
                  ],
                  rows: provider.parts.map((part) => DataRow(cells: [
                    DataCell(Text(part.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(part.quantity.toString())),
                    DataCell(Text(part.width.toStringAsFixed(1))),
                    DataCell(Text(part.length.toStringAsFixed(1))),
                    DataCell(Text(part.material)),
                    DataCell(Text(part.area.toStringAsFixed(3))),
                  ])).toList(),
                ),
              ),
            ),
          ),
          
          // Alt Bilgi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Toplam ${provider.parts.length} kalem parça listelendi.",
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }
}