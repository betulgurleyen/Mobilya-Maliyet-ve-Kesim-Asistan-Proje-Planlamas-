class CostSettings {
  // Gövde
  String bodyMaterialName;
  double bodyPlatePrice;
  
  // Kapak
  String coverMaterialName;
  double coverPlatePrice;
  
  // Ray Çeşitleri
  double railPriceWhite;       // Beyaz Ray
  double railPriceTelescopic;  // Teleskopik Ray
  double railPriceSmart;       // Smart Ray
  
  // Menteşe Çeşitleri
  double hingePriceStop;       // Stoplu
  double hingePriceNonStop;    // Stopsuz
  
  // Diğer
  double handlePrice;
  double legPrice;
  double pvcPricePerMeter;
  
  // Standart Ölçüler (Varsayılan)
  double plateWidth;
  double plateHeight;

  CostSettings({
    this.bodyMaterialName = 'Suntalam (210x280 cm)',
    this.bodyPlatePrice = 0.0,
    this.coverMaterialName = 'Suntalam (210x280 cm)',
    this.coverPlatePrice = 0.0,
    this.railPriceWhite = 0.0,
    this.railPriceTelescopic = 0.0,
    this.railPriceSmart = 0.0,
    this.hingePriceStop = 0.0,
    this.hingePriceNonStop = 0.0,
    this.handlePrice = 0.0,
    this.legPrice = 0.0,
    this.pvcPricePerMeter = 0.0,
    this.plateWidth = 210.0,
    this.plateHeight = 280.0,
  });
}