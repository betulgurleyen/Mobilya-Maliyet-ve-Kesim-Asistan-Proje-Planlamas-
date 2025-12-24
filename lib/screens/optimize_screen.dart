import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import 'cost_screen.dart';

class OptimizeScreen extends StatelessWidget {
  const OptimizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<ProjectProvider>();
    // Eğer hiç parça yoksa 0 plaka, varsa en az 1 veya hesaplanan kadar
    int plateCount = provider.theoreticalBodyPlateCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Optimize Kesim Planı"),
        actions: [
          // Sağ üstteki buton Maliyet sayfasına götürür
          TextButton.icon(
            icon: const Icon(Icons.attach_money, color: Colors.black),
            label: const Text("Maliyet", style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CostScreen())),
          )
        ],
      ),
      body: plateCount == 0 
          ? const Center(child: Text("Hesaplanacak parça bulunamadı. Lütfen modül ekleyin.")) 
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Toplam İhtiyaç: $plateCount Plaka",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: plateCount,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueGrey,
                                child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text("Plaka #${index + 1}"),
                              subtitle: Text("Malzeme: ${provider.settings.bodyMaterialName}"),
                              trailing: const Text("%85 Doluluk (Temsili)"),
                            ),
                            // Temsili Plaka Görseli
                            Container(
                              height: 180,
                              width: double.infinity,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7CCC8), // Ahşap rengi
                                border: Border.all(color: Colors.brown, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      "210 x 280 cm\nKesim Alanı",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.brown[800], fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  // Buraya ileride gerçek parça çizimleri (CustomPainter) gelecek
                                  // Şimdilik görsel zenginlik için temsili bir kutu koyalım
                                  Positioned(
                                    top: 10, left: 10,
                                    child: Container(width: 50, height: 100, color: Colors.brown[400]),
                                  ),
                                  Positioned(
                                    top: 10, left: 70,
                                    child: Container(width: 50, height: 50, color: Colors.brown[400]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}