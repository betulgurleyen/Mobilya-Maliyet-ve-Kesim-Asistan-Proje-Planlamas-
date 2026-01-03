import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cost_settings.dart';
import '../models/cutting_part.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../services/firestore_service.dart'; 

class ProjectProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  Box? _settingsBox;
  String? currentFirebaseId; // Projenin veritabanı ID'sini tutacak

  CostSettings settings = CostSettings();
  
  // 1. Detaylı Parça Listesi (Kesim Ekranı İçin)
  List<CuttingPart> parts = [];
  
  // 2. Özet Modül Listesi (Ekleme Ekranı İçin)
  List<Map<String, dynamic>> addedModules = [];

  int manualBodyPlateCount = 0;

  ProjectProvider() {
    if (Hive.isBoxOpen('app_settings')) {
      _settingsBox = Hive.box('app_settings');
      _loadSettingsFromHive();
    }
  }

  void _loadSettingsFromHive() {
    if (_settingsBox == null) return;
    settings = CostSettings(
      bodyMaterialName: _settingsBox!.get('bodyMaterialName', defaultValue: 'Suntalam'),
      bodyPlatePrice: _settingsBox!.get('bodyPlatePrice', defaultValue: 0.0),
      plateWidth: _settingsBox!.get('plateWidth', defaultValue: 210.0),
      plateHeight: _settingsBox!.get('plateHeight', defaultValue: 280.0),
    );
    notifyListeners();
  }

  void updateSettings(CostSettings newSettings) {
    if (_settingsBox == null) return;
    settings = newSettings;
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
    bool coverEqual = true, 
    String handleType = "Standart",
    List<double>? manualWidths,  
    List<double>? manualHeights, 
    String? rayType,
    bool hasMicrowave = false,
    String? drawerConfig,
    int fridgePostCount = 0,
    double fridgePostDepth = 0,
    bool hasTopPanel = false,
    String? extraPartName,
    String? extraMaterial,
    bool isTacli = false,
  }) {
    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

    // --- DETAYLI METİN OLUŞTURMA ---
    String extraInfoText = "";
    
    if (drawerConfig != null) extraInfoText += "$drawerConfig (Çekmece), ";
    
    if (rayType != null && rayType != "Beyaz") {
       extraInfoText += "$rayType Ray, ";
    } else if (rayType == "Beyaz") {
       extraInfoText += "Beyaz Ray, ";
    }

    if (handleType != "Normal" && handleType != "Standart") {
      extraInfoText += "$handleType Kulp, ";
    }

    if (hasMicrowave) extraInfoText += "Mikrodalga Yeri Var, ";
    if (isTacli) extraInfoText += "Taçlı Model, ";
    if (fridgePostCount > 0) extraInfoText += "$fridgePostCount Adet Dikme, ";
    if (hasTopPanel) extraInfoText += "Üst Tabla Var, ";

    if (extraInfoText.endsWith(", ")) extraInfoText = extraInfoText.substring(0, extraInfoText.length - 2);

    // Modülü Özet Listesine Ekle
    addedModules.add({
      'id': uniqueId,
      'type': type,
      'quantity': quantity,
      'width': width,
      'height': height,
      'depth': depth,
      'shelfCount': shelfCount,
      'coverCount': coverCount,
      'coverEqual': coverEqual,
      'handleType': handleType,
      'manualWidths': manualWidths,
      'manualHeights': manualHeights,
      'rayType': rayType,
      'hasMicrowave': hasMicrowave,
      'drawerConfig': drawerConfig,
      'fridgePostCount': fridgePostCount,
      'fridgePostDepth': fridgePostDepth,
      'hasTopPanel': hasTopPanel,
      'isTacli': isTacli,
      'extraPartName': extraPartName, 
      'extraMaterial': extraMaterial,
      'extraInfo': extraInfoText, 
    });

    // Parçaları Hesapla
    _calculateAndAddParts(
      moduleId: uniqueId,
      type: type, quantity: quantity, width: width, height: height, depth: depth,
      shelfCount: shelfCount, coverCount: coverCount, coverEqual: coverEqual,
      handleType: handleType, manualWidths: manualWidths, manualHeights: manualHeights,
      rayType: rayType, hasMicrowave: hasMicrowave, drawerConfig: drawerConfig,
      fridgePostCount: fridgePostCount, fridgePostDepth: fridgePostDepth,
      hasTopPanel: hasTopPanel, extraPartName: extraPartName, extraMaterial: extraMaterial,
      isTacli: isTacli
    );

    notifyListeners();
  }

  // --- MODÜL SİLME ---
  void removeModuleById(String id) {
    parts.removeWhere((part) => part.moduleId == id);
    addedModules.removeWhere((mod) => mod['id'] == id);
    notifyListeners();
  }

  // --- PARÇA HESAPLAMA (GİZLİ) ---
  void _calculateAndAddParts({
    required String moduleId, 
    required String type, required int quantity, required double width, required double height, required double depth,
    int shelfCount = 0, int coverCount = 0, bool coverEqual = true, String handleType = "",
    List<double>? manualWidths, List<double>? manualHeights, String? rayType,
    bool hasMicrowave = false, String? drawerConfig, int fridgePostCount = 0, double fridgePostDepth = 0,
    bool hasTopPanel = false, String? extraPartName, String? extraMaterial, bool isTacli = false,
  }) {
    double materialThickness = 1.8; 

    if (type == "Ek Parça") {
      parts.add(CuttingPart(
        moduleId: moduleId,
        name: extraPartName ?? "Ek Parça", width: width, length: height,
        material: extraMaterial ?? settings.bodyMaterialName, quantity: quantity,
      ));
      return;
    }

    // Yanlar
    parts.add(CuttingPart(moduleId: moduleId, name: "$type - Yan", width: depth, length: height, material: settings.bodyMaterialName, quantity: 2 * quantity));

    // Alt
    parts.add(CuttingPart(moduleId: moduleId, name: "$type - Alt", width: depth, length: width - (2 * materialThickness), material: settings.bodyMaterialName, quantity: 1 * quantity));

    // Üst
    bool skipTop = (type == "Çekmece (Serbest)" && !hasTopPanel) || (type == "Buzdolabı"); 
    if (!skipTop) {
      parts.add(CuttingPart(moduleId: moduleId, name: "$type - Üst", width: depth, length: width - (2 * materialThickness), material: settings.bodyMaterialName, quantity: 1 * quantity));
    }

    // Arkalık
    if (type != "Buzdolabı") {
       parts.add(CuttingPart(moduleId: moduleId, name: "$type - Arkalık", width: width, length: height, material: "Duralit/Arkalık", quantity: 1 * quantity));
    }

    // Raflar
    if (shelfCount > 0) {
      parts.add(CuttingPart(moduleId: moduleId, name: "$type - Raf", width: depth - 5, length: width - (2 * materialThickness), material: settings.bodyMaterialName, quantity: shelfCount * quantity));
    }

    // Özel
    if (type == "Buzdolabı" && fridgePostCount > 0) {
      parts.add(CuttingPart(moduleId: moduleId, name: "$type - Dikme", width: fridgePostDepth > 0 ? fridgePostDepth : depth, length: height, material: settings.bodyMaterialName, quantity: fridgePostCount * quantity));
      if (isTacli) {
         parts.add(CuttingPart(moduleId: moduleId, name: "$type - Taç", width: 15, length: width, material: settings.coverMaterialName, quantity: 1 * quantity));
      }
    }
    
    if (hasMicrowave) {
       parts.add(CuttingPart(moduleId: moduleId, name: "$type - Mikrodalga Rafı", width: depth, length: width - (2 * materialThickness), material: settings.bodyMaterialName, quantity: 1 * quantity));
    }

    // Kapaklar
    if (coverCount > 0) {
      bool isVerticalStack = (type == "Boy Dolap" || type == "Ankastre Boy" || type == "Çekmece"); 
      String coverName = (type.contains("Çekmece")) ? "$type Önü" : "$type Kapak";
      
      if (isVerticalStack) {
        double singleW = width - 0.4;
        if (!coverEqual && manualHeights != null && manualHeights.isNotEmpty) {
          for (int i = 0; i < coverCount; i++) {
            double h = (i < manualHeights.length) ? manualHeights[i] : (height / coverCount);
            parts.add(CuttingPart(moduleId: moduleId, name: "$coverName ${i + 1}", width: singleW, length: h - 0.4, material: settings.coverMaterialName, quantity: 1 * quantity, isCover: true));
          }
        } else {
          double equalH = (height / coverCount) - 0.4;
          parts.add(CuttingPart(moduleId: moduleId, name: coverName, width: singleW, length: equalH, material: settings.coverMaterialName, quantity: coverCount * quantity, isCover: true));
        }
      } else {
        double singleH = height - 0.4;
        if (!coverEqual && manualWidths != null && manualWidths.isNotEmpty) {
          for (int i = 0; i < coverCount; i++) {
            double w = (i < manualWidths.length) ? manualWidths[i] : (width / coverCount);
            parts.add(CuttingPart(moduleId: moduleId, name: "$coverName ${i + 1}", width: w - 0.4, length: singleH, material: settings.coverMaterialName, quantity: 1 * quantity, isCover: true));
          }
        } else {
          double equalW = (width / coverCount) - 0.4;
          parts.add(CuttingPart(moduleId: moduleId, name: coverName, width: equalW, length: singleH, material: settings.coverMaterialName, quantity: coverCount * quantity, isCover: true));
        }
      }
    }
  }

  // --- HESAPLAMALAR ---
  double get totalBodyArea {
    double area = 0;
    for (var part in parts) { if (!part.isCover) area += (part.width * part.length * part.quantity); }
    return area / 10000; 
  }

  int get theoreticalBodyPlateCount {
    double plateArea = (settings.plateWidth * settings.plateHeight) / 10000;
    if (plateArea == 0) return 0;
    return (totalBodyArea / plateArea).ceil();
  }

  double get totalProjectCost {
    int plateCount = manualBodyPlateCount > 0 ? manualBodyPlateCount : theoreticalBodyPlateCount;
    return plateCount * settings.bodyPlatePrice;
  }
  
  void setManualPlateCount(int count) { manualBodyPlateCount = count; notifyListeners(); }
  void removePart(int index) { if (index >= 0 && index < parts.length) { parts.removeAt(index); notifyListeners(); } }

  // --- FIREBASE KAYIT (DÜZELTME: Method adı 'saveProject' olarak güncellendi) ---
 Future<void> saveProject(String projectName) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("Kullanıcı girişi yapılmamış.");
  if (addedModules.isEmpty) throw Exception("Kaydedilecek modül yok.");

  try {
    if (currentFirebaseId != null) {
      // --- GÜNCELLEME MODU ---
      // Eğer bu proje daha önce yüklenmişse, üzerine yaz.
      await _firestoreService.updateProject(
        userId: user.uid,
        projectId: currentFirebaseId!,
        projectName: projectName,
        modules: addedModules,
        totalCost: totalProjectCost,
      );
      print("BAŞARILI: Proje Güncellendi.");
    } else {
      // --- YENİ KAYIT MODU ---
      // ID yoksa sıfırdan oluştur.
      await _firestoreService.saveProject(
        userId: user.uid,
        projectName: projectName,
        modules: addedModules,
        totalCost: totalProjectCost,
      );
      print("BAŞARILI: Yeni Proje Oluşturuldu.");
    }
  } catch (e) {
    print("KAYIT HATASI: $e");
    rethrow;
  }
}

  // --- FIREBASE'DEN YÜKLEME ---
 // --- FIREBASE'DEN YÜKLEME FONKSİYONU ---
  // saved_projects_screen.dart sayfasından çağrılır.
  void loadProjectFromFirebase(Map<String, dynamic> projectData, String documentId) {
    // 1. Proje ID'sini hafızaya al (Daha sonra güncelleme yapabilmek için)
    currentFirebaseId = documentId;

    // 2. Mevcut ekranı temizle
    parts.clear();
    addedModules.clear();

    // 3. Veritabanından gelen modülleri al
    List<dynamic> savedModules = projectData['modules'] ?? [];

    // 4. Her bir modülü tekrar sisteme ekle ve parçalarını hesaplat
    for (var mod in savedModules) {
      // Modül listesine ham veriyi ekle
      addedModules.add(mod);

      // Hesaplama motorunu çalıştır (Parçaları oluşturur)
      _calculateAndAddParts(
        moduleId: mod['id'],
        type: mod['type'],
        quantity: mod['quantity'],
        width: (mod['width'] as num).toDouble(),
        height: (mod['height'] as num).toDouble(),
        depth: (mod['depth'] as num).toDouble(),
        shelfCount: mod['shelfCount'] ?? 0,
        coverCount: mod['coverCount'] ?? 0,
        coverEqual: mod['coverEqual'] ?? true,
        handleType: mod['handleType'] ?? "Standart",
        rayType: mod['rayType'],
        hasMicrowave: mod['hasMicrowave'] ?? false,
        drawerConfig: mod['drawerConfig'],
        fridgePostCount: mod['fridgePostCount'] ?? 0,
        fridgePostDepth: (mod['fridgePostDepth'] as num?)?.toDouble() ?? 0,
        hasTopPanel: mod['hasTopPanel'] ?? false,
        extraPartName: mod['extraPartName'],
        extraMaterial: mod['extraMaterial'],
        isTacli: mod['isTacli'] ?? false,
        manualWidths: (mod['manualWidths'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
        manualHeights: (mod['manualHeights'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      );
    }
    // Ekranı yenile
    notifyListeners();
  }
  // Sayfa temizlendiğinde veya yeni proje dendiğinde çağır
  void clearProject() {
    addedModules.clear();
    parts.clear();
    currentFirebaseId = null; // ID'yi unut, artık yeni bir sayfa açıldı
    notifyListeners();
  }
}