import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cost_settings.dart';
import '../models/cutting_part.dart';

class ProjectProvider with ChangeNotifier {
  final _settingsBox = Hive.box('app_settings');

  CostSettings settings = CostSettings();
  List<CuttingPart> parts = [];
  List<Map<String, dynamic>> addedModules = []; 
  int manualBodyPlateCount = 0;

  ProjectProvider() {
    _loadSettingsFromHive();
  }

  // --- AYARLARI YÜKLE ---
  void _loadSettingsFromHive() {
    if (_settingsBox.isNotEmpty) {
      settings = CostSettings(
        bodyMaterialName: _settingsBox.get('bodyMaterialName', defaultValue: 'Suntalam (210x280 cm)'),
        bodyPlatePrice: _settingsBox.get('bodyPlatePrice', defaultValue: 0.0),
        
        coverMaterialName: _settingsBox.get('coverMaterialName', defaultValue: 'Suntalam (210x280 cm)'),
        coverPlatePrice: _settingsBox.get('coverPlatePrice', defaultValue: 0.0),
        
        railPriceWhite: _settingsBox.get('railPriceWhite', defaultValue: 0.0),
        railPriceTelescopic: _settingsBox.get('railPriceTelescopic', defaultValue: 0.0),
        railPriceSmart: _settingsBox.get('railPriceSmart', defaultValue: 0.0),
        
        hingePriceStop: _settingsBox.get('hingePriceStop', defaultValue: 0.0),
        hingePriceNonStop: _settingsBox.get('hingePriceNonStop', defaultValue: 0.0),
        
        handlePrice: _settingsBox.get('handlePrice', defaultValue: 0.0),
        legPrice: _settingsBox.get('legPrice', defaultValue: 0.0),
        pvcPricePerMeter: _settingsBox.get('pvcPricePerMeter', defaultValue: 0.0),
      );
      notifyListeners();
    }
  }

  // --- AYARLARI KAYDET ---
  void updateSettings(CostSettings newSettings) {
    settings = newSettings;
    
    _settingsBox.put('bodyMaterialName', newSettings.bodyMaterialName);
    _settingsBox.put('bodyPlatePrice', newSettings.bodyPlatePrice);
    
    _settingsBox.put('coverMaterialName', newSettings.coverMaterialName);
    _settingsBox.put('coverPlatePrice', newSettings.coverPlatePrice);
    
    _settingsBox.put('railPriceWhite', newSettings.railPriceWhite);
    _settingsBox.put('railPriceTelescopic', newSettings.railPriceTelescopic);
    _settingsBox.put('railPriceSmart', newSettings.railPriceSmart);
    
    _settingsBox.put('hingePriceStop', newSettings.hingePriceStop);
    _settingsBox.put('hingePriceNonStop', newSettings.hingePriceNonStop);
    
    _settingsBox.put('handlePrice', newSettings.handlePrice);
    _settingsBox.put('legPrice', newSettings.legPrice);
    _settingsBox.put('pvcPricePerMeter', newSettings.pvcPricePerMeter);
    
    notifyListeners();
  }

  // --- MODÜL EKLEME ---
  void addModule({
    required String type,
    required int quantity,
    required double width,
    required double height,
    required double depth,
    required int shelfCount,
    required int coverCount,
  }) {
    addedModules.add({'type': type, 'qty': quantity, 'w': width, 'h': height, 'd': depth});
    double materialThickness = 1.8; 

    // Yan Dikmeler
    parts.add(CuttingPart(
      name: "$type Yan Dikme",
      width: depth,
      length: height,
      material: settings.bodyMaterialName,
      quantity: 2 * quantity,
    ));

    // Alt/Üst Tabla
    parts.add(CuttingPart(
      name: "$type Alt/Üst Tabla",
      width: depth,
      length: width - (2 * materialThickness),
      material: settings.bodyMaterialName,
      quantity: 2 * quantity,
    ));

    // Arkalık
    parts.add(CuttingPart(
      name: "$type Arkalık",
      width: width,
      length: height,
      material: "Duralit/Arkalık",
      quantity: 1 * quantity,
    ));

    // Kapaklar (Artık seçilen kapak malzemesini kullanıyor)
    if (coverCount > 0) {
      parts.add(CuttingPart(
        name: "$type Kapak",
        width: (width / coverCount) - 0.4,
        length: height - 0.4,
        material: settings.coverMaterialName, 
        quantity: coverCount * quantity,
        isCover: true,
      ));
    }
    notifyListeners();
  }

  double get totalBodyArea {
    double area = 0;
    for (var part in parts) {
      if (!part.isCover) area += (part.width * part.length * part.quantity);
    }
    return area / 10000; 
  }

  int get theoreticalBodyPlateCount {
    double plateArea = (settings.plateWidth * settings.plateHeight) / 10000;
    if (plateArea == 0) return 0;
    return (totalBodyArea / plateArea).ceil();
  }

  double get totalProjectCost {
    int plateCount = manualBodyPlateCount > 0 ? manualBodyPlateCount : theoreticalBodyPlateCount;
    // Basit maliyet hesabı (Detaylandırılabilir)
    return plateCount * settings.bodyPlatePrice;
  }
  
  void setManualPlateCount(int count) {
    manualBodyPlateCount = count;
    notifyListeners();
  }
}