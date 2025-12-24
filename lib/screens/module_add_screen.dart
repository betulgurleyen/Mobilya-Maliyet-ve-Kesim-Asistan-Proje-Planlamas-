import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import 'cutting_list_screen.dart';
// import 'cutting_list_screen.dart'; // Bir sonraki adımda ekleyeceğiz

class ModuleAddScreen extends StatefulWidget {
  const ModuleAddScreen({super.key});

  @override
  State<ModuleAddScreen> createState() => _ModuleAddScreenState();
}

class _ModuleAddScreenState extends State<ModuleAddScreen> {
  // Input Controllerları
  final wCtrl = TextEditingController();
  final hCtrl = TextEditingController();
  final dCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: "1");
  String selectedType = "Alt Dolap";

  @override
  Widget build(BuildContext context) {
    // Provider'ı dinliyoruz (eklenen parçaları anlık görmek için)
    var provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modül Ekleme"),
        actions: [
           TextButton.icon(
             icon: const Icon(Icons.arrow_forward, color: Colors.black),
             label: const Text("Kesim Listesi", style: TextStyle(color: Colors.black)),
             onPressed: () {
               // Bir sonraki adımda burayı açacağız
               // Navigator.push(context, MaterialPageRoute(builder: (_) => const CuttingListScreen()));
               Navigator.push(context, MaterialPageRoute(builder: (_) => const CuttingListScreen()));
             },
           )
        ],
      ),
      body: Column(
        children: [
          // ÜST KISIM: FORM
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ListView(
                children: [
                  DropdownButtonFormField(
                    value: selectedType,
                    items: ["Alt Dolap", "Üst Dolap", "Boy Dolabı"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => selectedType = v.toString()),
                    decoration: const InputDecoration(labelText: "Modül Türü", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _buildInput(wCtrl, "Genişlik (cm)")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInput(hCtrl, "Yükseklik (cm)")),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _buildInput(dCtrl, "Derinlik (cm)")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInput(qtyCtrl, "Adet")),
                  ]),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calculate),
                    label: const Text("Modülü Hesapla ve Ekle"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15)
                    ),
                    onPressed: () {
                      if (wCtrl.text.isEmpty || hCtrl.text.isEmpty) return;

                      context.read<ProjectProvider>().addModule(
                        type: selectedType,
                        quantity: int.tryParse(qtyCtrl.text) ?? 1,
                        width: double.tryParse(wCtrl.text) ?? 0,
                        height: double.tryParse(hCtrl.text) ?? 0,
                        depth: double.tryParse(dCtrl.text) ?? 0,
                        shelfCount: 1, // Şimdilik sabit
                        coverCount: 2, // Şimdilik sabit
                      );
                      
                      // Klavye kapansın ve bilgi verilsin
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Parçalar listeye eklendi!")));
                    },
                  )
                ],
              ),
            ),
          ),
          
          const Divider(thickness: 2),

          // ALT KISIM: LİSTE ÖNİZLEME
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("Oluşan Parçalar (Önizleme)", style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                    child: provider.parts.isEmpty 
                    ? const Center(child: Text("Henüz modül eklemediniz."))
                    : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                          columns: const [
                            DataColumn(label: Text("Parça Adı")),
                            DataColumn(label: Text("En")),
                            DataColumn(label: Text("Boy")),
                            DataColumn(label: Text("Adet")),
                            DataColumn(label: Text("Malzeme")),
                          ],
                          rows: provider.parts.map((part) => DataRow(cells: [
                            DataCell(Text(part.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(part.width.toStringAsFixed(1))),
                            DataCell(Text(part.length.toStringAsFixed(1))),
                            DataCell(Text(part.quantity.toString())),
                            DataCell(Text(part.material, style: const TextStyle(fontSize: 12))),
                          ])).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String label) {
    return TextFormField(
      controller: c, 
      keyboardType: TextInputType.number, 
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())
    );
  }
}