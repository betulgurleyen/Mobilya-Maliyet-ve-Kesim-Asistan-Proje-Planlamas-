class CuttingPart {
  final String name; 
  final double width;
  final double length;
  final String material;
  final int quantity;
  final bool isCover;

  // Detaylar
  final String? moduleType;       
  final double? moduleWidth;      
  final double? moduleDepth;      
  final double? moduleHeight;     
  final String? extraInfo;
  
  // YENİ: Bu parça hangi modül paketine ait? (Silme işlemi için şart)
  final String? moduleId; 

  CuttingPart({
    required this.name,
    required this.width,
    required this.length,
    required this.material,
    required this.quantity,
    this.isCover = false,
    this.moduleType,
    this.moduleWidth,
    this.moduleDepth,
    this.moduleHeight,
    this.extraInfo,
    this.moduleId, // Yeni alan
  });

  double get area => (width * length * quantity) / 10000; 
}

class MobilyaModulu {
  final String ad;
  final double genislik; // cm cinsinden
  final double yukseklik; // cm cinsinden
  final String malzemeCinsi; // Örn: MDF, Sunta

  MobilyaModulu({required this.ad, required this.genislik, required this.yukseklik, required this.malzemeCinsi});
}

class Plaka {
  final String cins;
  final double fiyat; // Plaka başı fiyat
  final int adet;

  Plaka({required this.cins, required this.fiyat, required this.adet});
}