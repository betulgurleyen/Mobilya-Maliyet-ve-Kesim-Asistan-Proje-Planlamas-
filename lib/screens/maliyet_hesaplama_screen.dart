import 'package:flutter/material.dart';
import '../models/cutting_part.dart';
import '../models/cost_settings.dart';

class MaliyetHesaplamaPage extends StatefulWidget {
  final List<Plaka> kullanilanPlakalar;

  const MaliyetHesaplamaPage({Key? key, required this.kullanilanPlakalar}) : super(key: key);

  @override
  _MaliyetHesaplamaPageState createState() => _MaliyetHesaplamaPageState();
}

class _MaliyetHesaplamaPageState extends State<MaliyetHesaplamaPage> {
  double isclikUcreti = 500.0; // Varsayılan işçilik
  double aksesuarUcreti = 200.0; // Menteşe, kulp vs.

  double toplamTutarHesapla() {
    double plakaTutari = widget.kullanilanPlakalar.fold(0, (sum, item) => sum + (item.fiyat * item.adet));
    return plakaTutari + isclikUcreti + aksesuarUcreti;
  }

  void projeyiKaydet() {
    // Burada veritabanına kayıt işlemi yapılır (Firebase, SQLite veya SharedPreferences)
    // Örnek olarak sadece kullanıcıya bilgi veriyoruz.
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Başarılı"),
        content: Text("Proje ve maliyet tablosu başarıyla kaydedildi!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog kapat
              Navigator.popUntil(context, (route) => route.isFirst); // Ana sayfaya dön
            },
            child: Text("Tamam"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double toplam = toplamTutarHesapla();

    return Scaffold(
      appBar: AppBar(title: Text("Maliyet Hesaplama")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gider Kalemleri", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            SizedBox(height: 20),
            
            // Plaka Listesi
            Expanded(
              child: ListView.builder(
                itemCount: widget.kullanilanPlakalar.length,
                itemBuilder: (context, index) {
                  var plaka = widget.kullanilanPlakalar[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.table_restaurant, color: Colors.brown),
                      title: Text("${plaka.cins}"),
                      subtitle: Text("${plaka.adet} Adet x ${plaka.fiyat} TL"),
                      trailing: Text("${plaka.adet * plaka.fiyat} TL", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
            
            Divider(thickness: 2),
            
            // Ek Giderler
            ListTile(
              title: Text("İşçilik Ücreti"),
              trailing: Text("$isclikUcreti TL"),
            ),
            ListTile(
              title: Text("Aksesuar / Hırdavat"),
              trailing: Text("$aksesuarUcreti TL"),
            ),

            Divider(thickness: 2),

            // Toplam Fiyat
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TOPLAM MALİYET:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("$toplam TL", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800])),
                ],
              ),
            ),
            
            SizedBox(height: 20),

            // Kaydet Butonu
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: projeyiKaydet,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text("Projeyi Kaydet ve Bitir", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}