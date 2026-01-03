import 'package:flutter/material.dart';
import '../models/cutting_part.dart';
import '../models/cost_settings.dart';
import 'maliyet_hesaplama_screen.dart'; // Maliyet sayfası importu

class OptimizeScreen extends StatefulWidget {
  final List<MobilyaModulu> secilenModuller;

  const OptimizeScreen({Key? key, required this.secilenModuller}) : super(key: key);

  @override
  _OptimizeScreenState createState() => _OptimizeScreenState();
}

class _OptimizeScreenState extends State<OptimizeScreen> {
  // --- SABİT PLAKA ÖLÇÜLERİ (User Request: 180x210) ---
  // Genellikle mobilyada uzun kenar Y ekseni alınır ama ekrana sığması için 
  // Genişlik: 210, Yükseklik: 180 olarak ayarladım. İstersen yer değiştirebilirsin.
  final double plakaGenislik = 210.0;
  final double plakaYukseklik = 180.0;
  final double bicakPayi = 0.4; // Kesim bıçağı payı (mm cinsinden değil cm cinsinden, örn 4mm)

  // Hesaplanan yerleşim verilerini tutacak liste
  // Her eleman bir plakayı temsil eder. İçindeki Rect listesi o plakadaki parçalardır.
  List<List<YerlesimParcasi>> plakalarListesi = [];

  @override
  void initState() {
    super.initState();
    _yerlesimiHesapla();
  }

  // --- BASİT YERLEŞTİRME ALGORİTMASI (Next-Fit / Raf Sistemi) ---
  void _yerlesimiHesapla() {
    // 1. Parçaları kopyala ve büyükten küçüğe sırala (Optimize etmek için)
    List<MobilyaModulu> siraliParcalar = List.from(widget.secilenModuller);
    siraliParcalar.sort((a, b) => (b.genislik * b.yukseklik).compareTo(a.genislik * a.yukseklik));

    List<YerlesimParcasi> aktifPlakaParcalari = [];
    double currentX = 0;
    double currentY = 0;
    double satirYuksekligi = 0;

    for (var parca in siraliParcalar) {
      // Parça plakadan büyükse sığmaz, bunu atla veya uyarı ver
      if (parca.genislik > plakaGenislik || parca.yukseklik > plakaYukseklik) {
        debugPrint("${parca.ad} plakadan büyük, sığdırılamadı!");
        continue;
      }

      // 2. Mevcut satıra sığmıyorsa alt satıra geç
      if (currentX + parca.genislik > plakaGenislik) {
        currentX = 0;
        currentY += satirYuksekligi + bicakPayi; // Alt satıra in
        satirYuksekligi = 0; // Yeni satır yüksekliği sıfırla
      }

      // 3. Mevcut plakaya sığmıyorsa YENİ PLAKAYA geç
      if (currentY + parca.yukseklik > plakaYukseklik) {
        // Şu anki plakayı kaydet
        plakalarListesi.add(List.from(aktifPlakaParcalari));
        aktifPlakaParcalari.clear();
        
        // Koordinatları sıfırla
        currentX = 0;
        currentY = 0;
        satirYuksekligi = 0;
      }

      // 4. Parçayı yerleştir
      aktifPlakaParcalari.add(YerlesimParcasi(
        rect: Rect.fromLTWH(currentX, currentY, parca.genislik, parca.yukseklik),
        ad: parca.ad,
        olcu: "${parca.genislik.toInt()}x${parca.yukseklik.toInt()}"
      ));

      // Koordinatları güncelle
      currentX += parca.genislik + bicakPayi;
      
      // Satır yüksekliğini güncelle (Satırdaki en uzun parça kadar olmalı)
      if (parca.yukseklik > satirYuksekligi) {
        satirYuksekligi = parca.yukseklik;
      }
    }

    // Son kalan plakayı da ekle
    if (aktifPlakaParcalari.isNotEmpty) {
      plakalarListesi.add(aktifPlakaParcalari);
    }
    
    // Eğer hiç parça yoksa boş bir plaka gösterelim hata vermesin
    if (plakalarListesi.isEmpty) {
      plakalarListesi.add([]);
    }

    setState(() {}); // Ekranı güncelle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kesim Planı (180x210)")),
      body: Column(
        children: [
          // Bilgi Kartı
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bilgiKutusu("Plaka Boyutu", "${plakaGenislik.toInt()} x ${plakaYukseklik.toInt()} cm", Colors.blue),
                _bilgiKutusu("Gereken Plaka", "${plakalarListesi.length} Adet", Colors.orange),
              ],
            ),
          ),

          const Divider(),
          const Text("Sayfaları kaydırarak diğer plakalara bakabilirsiniz", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),

          // --- GÖRSELLEŞTİRME ALANI (PageView) ---
          Expanded(
            child: PageView.builder(
              itemCount: plakalarListesi.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text("PLAKA ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FittedBox(
                          // FittedBox: Çizimi ekrana orantılı sığdırır
                          child: SizedBox(
                            width: plakaGenislik, // 210 birim
                            height: plakaYukseklik, // 180 birim
                            child: CustomPaint(
                              painter: PlakaPainter(
                                parcalar: plakalarListesi[index],
                                pGen: plakaGenislik,
                                pYuk: plakaYukseklik,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // --- MALİYET BUTONU ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green.shade700,
              ),
              icon: const Icon(Icons.calculate, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaliyetHesaplamaPage(
                      kullanilanPlakalar: [
                        Plaka(
                          cins: "MDF 180x210", 
                          fiyat: 1500, // Varsayılan fiyat, sonra değiştirebilirsin
                          adet: plakalarListesi.length
                        )
                      ],
                    ),
                  ),
                );
              },
              label: const Text("Maliyet Hesapla", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bilgiKutusu(String baslik, String deger, Color renk) {
    return Column(
      children: [
        Text(baslik, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(deger, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

// --- YARDIMCI SINIF: Çizim için gerekli verileri tutar ---
class YerlesimParcasi {
  final Rect rect;
  final String ad;
  final String olcu;

  YerlesimParcasi({required this.rect, required this.ad, required this.olcu});
}

// --- ÇİZİM MOTORU (CustomPainter) ---
class PlakaPainter extends CustomPainter {
  final List<YerlesimParcasi> parcalar;
  final double pGen;
  final double pYuk;

  PlakaPainter({required this.parcalar, required this.pGen, required this.pYuk});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ana Plaka Çerçevesi (Gri Zemin)
    final plakaBoya = Paint()..color = Colors.grey.shade300..style = PaintingStyle.fill;
    final cerceveBoya = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1;

    // Canvas size zaten FittedBox sayesinde bizim istediğimiz 210x180 oranında geliyor
    Rect plakaRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(plakaRect, plakaBoya);
    canvas.drawRect(plakaRect, cerceveBoya);

    // 2. Parçaların Çizimi
    final parcaBoya = Paint()..color = Colors.orange.shade300..style = PaintingStyle.fill;
    final parcaKenar = Paint()..color = Colors.brown.shade800..style = PaintingStyle.stroke..strokeWidth = 0.5;

    for (var parca in parcalar) {
      // Çizimdeki pozisyonu orantılamaya gerek yok çünkü canvas boyutunu FittedBox ile sabitledik.
      // Sadece 'size' üzerinden değil, direkt koordinatlarla çizebiliriz.
      // Ancak FittedBox'ın çalışma mantığı gereği size.width aslında pGen olmayabilir, ölçeklenmiş olabilir.
      // O yüzden basit bir scale faktörü kullanalım:
      
      double scaleX = size.width / pGen;
      double scaleY = size.height / pYuk;

      Rect r = Rect.fromLTWH(
        parca.rect.left * scaleX, 
        parca.rect.top * scaleY, 
        parca.rect.width * scaleX, 
        parca.rect.height * scaleY
      );

      canvas.drawRect(r, parcaBoya);
      canvas.drawRect(r, parcaKenar);

      // Yazı Yazma (Sadece parça çok küçük değilse)
      if (r.width > 15 && r.height > 10) {
        // Ölçü Yazısı
        TextSpan span = TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 3.5, fontWeight: FontWeight.bold), // Font boyutu küçük çünkü canvas koordinatları küçük
          text: parca.olcu
        );
        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(r.center.dx - tp.width / 2, r.center.dy - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}