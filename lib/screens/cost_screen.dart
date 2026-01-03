import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';

class CostScreen extends StatefulWidget {
  const CostScreen({super.key});

  @override
  State<CostScreen> createState() => _CostScreenState();
}

class _CostScreenState extends State<CostScreen> {
  // Manuel plaka sayısı girişi için kontrolcü
  final _manualPlateCtrl = TextEditingController();

  @override
  void dispose() {
    _manualPlateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Maliyet Hesaplama")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // BÖLÜM 1: MANUEL GİRİŞLER
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Manuel Düzenleme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text(
                    "Otomatik hesaplanan plaka sayısı yerine kendi belirlediğiniz sayıyı girmek için aşağıya yazın.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _manualPlateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Manuel Plaka Adedi",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                    onChanged: (val) {
                      provider.setManualPlateCount(int.tryParse(val) ?? 0);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // BÖLÜM 2: DETAY TABLOSU
          const Text("Maliyet Detayları", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildRow("Toplam Parça Alanı", "${provider.totalBodyArea.toStringAsFixed(2)} m²"),
                const Divider(height: 1),
                _buildRow("Plaka Birim Fiyatı", "${provider.settings.bodyPlatePrice} TL"),
                const Divider(height: 1),
                _buildRow(
                  "Hesaplanan Plaka Sayısı", 
                  "${provider.theoreticalBodyPlateCount} Adet",
                  isBold: true
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // BÖLÜM 3: GENEL TOPLAM KARTI
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.shade300, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                const Text("GENEL TOPLAM MALİYET", style: TextStyle(fontSize: 16, color: Colors.green)),
                const SizedBox(height: 10),
                Text(
                  "${provider.totalProjectCost.toStringAsFixed(2)} TL",
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                if (provider.manualBodyPlateCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                        SizedBox(width: 5),
                        Text("Manuel plaka adedi baz alındı", style: TextStyle(fontSize: 12, color: Colors.orange)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Projeyi Tamamla"),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Proje başarıyla tamamlandı!")));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.blueGrey,
              foregroundColor: const Color.fromARGB(255, 255, 254, 254),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}