import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../services/export_service.dart';
import 'optimize_screen.dart'; 
import '../models/cutting_part.dart';
import '../models/cost_settings.dart';
class CuttingListScreen extends StatelessWidget {
  const CuttingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<ProjectProvider>();
    final exportService = ExportService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Kesim Tablosu"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.blue),
            tooltip: "Projeyi Kaydet",
            onPressed: () => _showSaveDialog(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: "PDF Olarak Kaydet",
            onPressed: () async {
              if (provider.addedModules.isEmpty) return;
              await exportService.exportToPdf(
                  "Proje_1", provider.addedModules, provider.parts);
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_view, color: Colors.green),
            tooltip: "Excel Olarak İndir",
            onPressed: () async {
              if (provider.addedModules.isEmpty) return;
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Excel oluşturuluyor...")));
              await exportService.exportToExcel(
                  "Proje_1", provider.addedModules, provider.parts);
            },
          ),

          // --- DEĞİŞEN KISIM BURASI ---
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            tooltip: "Optimize Plana Git",
            onPressed: () {
              // 1. Eğer hiç parça yoksa uyarı ver
              if (provider.parts.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Optimize edilecek parça yok!")),
                );
                return;
              }

              // 2. Providerdaki parçaları MobilyaModulu formatına çevir
              List<MobilyaModulu> gonderilecekListe = [];

              for (var part in provider.parts) {
                // Parçanın adeti kadar listeye ekle (Örn: 2 adet kapak varsa 2 tane çizilsin)
                int adet = int.tryParse(part.quantity.toString()) ?? 1;
                
                for (int i = 0; i < adet; i++) {
                  gonderilecekListe.add(
                    MobilyaModulu(
                      ad: part.name,
                      // Veriler String geliyorsa double'a çeviriyoruz, hata olmasın diye tryParse kullandık
                      genislik: double.tryParse(part.width.toString()) ?? 0.0,
                      yukseklik: double.tryParse(part.length.toString()) ?? 0.0,
                      malzemeCinsi: part.material,
                    ),
                  );
                }
              }

              // 3. Optimize Sayfasına Git
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Not: Class ismini optimize_screen.dart içindekiyle aynı yaptığından emin ol (OptimizeScreen)
                  builder: (_) => OptimizeScreen(secilenModuller: gonderilecekListe),
                ),
              );
            },
          )
          // ---------------------------
        ],
      ),
      body: Column(
        children: [
          // --- ÜST BİLGİ BARI ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Toplam Modül: ${provider.addedModules.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  "Toplam Parça: ${provider.parts.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),

          // --- LİSTE VE TABLOLAR ---
          Expanded(
            child: provider.addedModules.isEmpty
                ? const Center(child: Text("Listelenecek parça yok."))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.addedModules.length,
                    itemBuilder: (context, index) {
                      final mod = provider.addedModules[index];
                      final moduleParts = provider.parts
                          .where((p) => p.moduleId == mod['id'])
                          .toList();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // --- KART BAŞLIĞI (GRİ ALAN) ---
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SOL TARAFA: Başlık ve Ölçüler
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${index + 1}. ${mod['type']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${mod['width']} x ${mod['height']} x ${mod['depth']} cm  (Adet: ${mod['quantity']})",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // --- PARÇA TABLOSU ---
                            moduleParts.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text("Parça yok"),
                                  )
                                : Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(3),   // Parça Adı
                                      1: FlexColumnWidth(1),   // Adet
                                      2: FlexColumnWidth(1.2), // En
                                      3: FlexColumnWidth(1.2), // Boy
                                      4: FlexColumnWidth(2),   // Malzeme
                                    },
                                    border: TableBorder(
                                      horizontalInside: BorderSide(
                                          color: Colors.grey.shade200, width: 1),
                                    ),
                                    children: [
                                      // --- BAŞLIK SATIRI ---
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          border: Border(bottom: BorderSide(color: Colors.black12))
                                        ),
                                        children: const [
                                          _HeaderCell("Parça", align: TextAlign.left),
                                          _HeaderCell("Adet"),
                                          _HeaderCell("En"),
                                          _HeaderCell("Boy"),
                                          _HeaderCell("MIZ", align: TextAlign.left),
                                        ],
                                      ),
                                      // --- VERİ SATIRLARI ---
                                      ...moduleParts.map((part) {
                                        return TableRow(
                                          children: [
                                            _DataCell(part.name, align: TextAlign.left),
                                            _DataCell("${part.quantity}", isBold: true),
                                            _DataCell("${part.width}"),
                                            _DataCell("${part.length}"),
                                            _DataCell(part.material, align: TextAlign.left, fontSize: 11, color: Colors.grey),
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  ),
                            
                            const SizedBox(height: 8),
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

  // --- KAYDETME PENCERESİ VE YARDIMCI WIDGETLAR AYNI KALDI ---
  void _showSaveDialog(BuildContext context, ProjectProvider provider) {
    // ... (Kodun geri kalanı aynı, burayı tekrar kopyalamana gerek yok)
    if (provider.addedModules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Kaydedilecek modül yok!"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();
    // ... Burası senin orijinal kodundaki gibi devam ediyor ...
    String dialogTitle = provider.currentFirebaseId != null ? "Projeyi Güncelle" : "Projeyi Kaydet";
    String dialogContent = provider.currentFirebaseId != null 
        ? "Mevcut projenin üzerine yazılacak." 
        : "Bu listeyi daha sonra tekrar düzenlemek için bir isim verin.";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dialogContent),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Örn: Ahmet Bey Mutfak",
                border: OutlineInputBorder(),
                labelText: "Proje Adı",
                prefixIcon: Icon(Icons.edit),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(ctx); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Proje işleniyor...")),
              );
              try {
                await provider.saveProject(nameController.text.trim());
                provider.clearProject();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("İşlem Başarılı! Yeni sayfa açıldı. ✅"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(provider.currentFirebaseId != null ? "GÜNCELLE" : "KAYDET"),
          ),
        ],
      ),
    );
  }
}

// ... _HeaderCell ve _DataCell sınıfları aynı, değiştirmeye gerek yok ...
class _HeaderCell extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _HeaderCell(this.text, {this.align = TextAlign.center});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool isBold;
  final TextAlign align;
  final double fontSize;
  final MaterialColor? color;

  const _DataCell(this.text, {
    this.isBold = false, 
    this.align = TextAlign.center, 
    this.fontSize = 13,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
          color: color ?? Colors.black87
        ),
      ),
    );
  }
}