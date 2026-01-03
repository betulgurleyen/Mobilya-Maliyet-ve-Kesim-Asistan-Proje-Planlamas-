import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cost_settings.dart';
import '../providers/project_provider.dart';
import 'module_add_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllerlar
  final _bodyPriceCtrl = TextEditingController();
  final _coverPriceCtrl = TextEditingController();
  
  final _railWhiteCtrl = TextEditingController();
  final _railTelescopicCtrl = TextEditingController();
  final _railSmartCtrl = TextEditingController();
  
  final _hingeStopCtrl = TextEditingController();
  final _hingeNonStopCtrl = TextEditingController();
  
  final _handleCtrl = TextEditingController();
  final _legCtrl = TextEditingController();
  final _pvcCtrl = TextEditingController();

  // Varsayılan Seçimler
  String _selectedBodyMaterial = "Suntalam (210x280 cm)";
  String _selectedCoverMaterial = "Suntalam (210x280 cm)";

  // GÖVDE MALZEMELERİ (1. Resimdeki Liste)
  final List<String> _bodyMaterials = [
    "Suntalam (210x280 cm)",
    "Mdflam (210x280 cm)",
  ];

  // KAPAK MALZEMELERİ (2. Resimdeki Geniş Liste)
  final List<String> _coverMaterials = [
    "Suntalam (210x280 cm)",
    "Mdflam (210x280 cm)",
    "HighGloss (122x280 cm)",
    "GlossMax (210x280 cm)",
    "Akrilik (122x280 cm)",
    "Balon",
    "Lake",
  ];

  @override
  void initState() {
    super.initState();
    // Kayıtlı verileri ekrana yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<ProjectProvider>().settings;
      _bodyPriceCtrl.text = settings.bodyPlatePrice.toString();
      _coverPriceCtrl.text = settings.coverPlatePrice.toString();
      _railWhiteCtrl.text = settings.railPriceWhite.toString();
      _railTelescopicCtrl.text = settings.railPriceTelescopic.toString();
      _railSmartCtrl.text = settings.railPriceSmart.toString();
      _hingeStopCtrl.text = settings.hingePriceStop.toString();
      _hingeNonStopCtrl.text = settings.hingePriceNonStop.toString();
      _handleCtrl.text = settings.handlePrice.toString();
      _legCtrl.text = settings.legPrice.toString();
      _pvcCtrl.text = settings.pvcPricePerMeter.toString();
      
      setState(() {
         // Eğer kayıtlı malzeme listede varsa onu seç, yoksa varsayılanı bırak
         if (_bodyMaterials.contains(settings.bodyMaterialName)) {
           _selectedBodyMaterial = settings.bodyMaterialName;
         }
         if (_coverMaterials.contains(settings.coverMaterialName)) {
           _selectedCoverMaterial = settings.coverMaterialName;
         }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(180, 223, 242, 218), // Resimdeki hafif gri arka plan
      appBar: AppBar(title: const Text("Genel Ayarlar")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- GÖVDE VE KAPAK BÖLÜMÜ ---
            // Gövde Malzemesi
            _buildDropdownRow("Gövde Malzemesi:", _selectedBodyMaterial, _bodyMaterials, (val) => setState(() => _selectedBodyMaterial = val!)),
            // Plaka Fiyatı
            _buildInputRow("Plaka Fiyatı (plaka / ₺):", _bodyPriceCtrl),
            
            const SizedBox(height: 15),
            
            // Kapak Malzemesi
            _buildDropdownRow("Kapak Malzemesi:", _selectedCoverMaterial, _coverMaterials, (val) => setState(() => _selectedCoverMaterial = val!)),
            // Kapak Plaka Fiyatı
            _buildInputRow("Kapak Plaka Fiyatı (plaka / ₺):", _coverPriceCtrl),

            const SizedBox(height: 25),

            // --- RAY TİPİ FİYATLARI ---
            _buildSectionHeader("Ray Tipi Fiyatları (adet / ₺):"),
            _buildInputRow("Beyaz Ray:", _railWhiteCtrl),
            _buildInputRow("Teleskopik Ray:", _railTelescopicCtrl),
            _buildInputRow("Smart Ray:", _railSmartCtrl),

            const SizedBox(height: 25),

            // --- MENTEŞE FİYATLARI ---
            _buildSectionHeader("Menteşe Fiyatları (adet / ₺):"),
            _buildInputRow("Stoplu Menteşe:", _hingeStopCtrl),
            _buildInputRow("Stopsuz Menteşe:", _hingeNonStopCtrl),

            const SizedBox(height: 15),

            // --- DİĞER ---
            _buildInputRow("Kulp Fiyatı (adet / ₺):", _handleCtrl),
            _buildInputRow("Ayak Fiyatı (adet / ₺):", _legCtrl),
            _buildInputRow("PVC Fiyatı (TL / metre):", _pvcCtrl),

            const SizedBox(height: 30),

            // --- KAYDET BUTONU ---
            Center(
              child: SizedBox(
                width: 150,
                height: 45,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: const Text("Kaydet", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    final newSettings = CostSettings(
      bodyMaterialName: _selectedBodyMaterial,
      bodyPlatePrice: double.tryParse(_bodyPriceCtrl.text) ?? 0,
      coverMaterialName: _selectedCoverMaterial,
      coverPlatePrice: double.tryParse(_coverPriceCtrl.text) ?? 0,
      
      railPriceWhite: double.tryParse(_railWhiteCtrl.text) ?? 0,
      railPriceTelescopic: double.tryParse(_railTelescopicCtrl.text) ?? 0,
      railPriceSmart: double.tryParse(_railSmartCtrl.text) ?? 0,
      
      hingePriceStop: double.tryParse(_hingeStopCtrl.text) ?? 0,
      hingePriceNonStop: double.tryParse(_hingeNonStopCtrl.text) ?? 0,
      
      handlePrice: double.tryParse(_handleCtrl.text) ?? 0,
      legPrice: double.tryParse(_legCtrl.text) ?? 0,
      pvcPricePerMeter: double.tryParse(_pvcCtrl.text) ?? 0,
    );

    context.read<ProjectProvider>().updateSettings(newSettings);
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ayarlar Kaydedildi!")));
    // İsterseniz burada diğer sayfaya yönlendirme yapabilirsiniz
     Navigator.push(context, MaterialPageRoute(builder: (_) => const ModuleAddScreen()));
  }

  // --- Yardımcı Widgetlar ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(label, textAlign: TextAlign.end, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: SizedBox(
              height: 35, // İnput yüksekliğini resimdeki gibi kıstık
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(label, textAlign: TextAlign.end, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: SizedBox(
              height: 35,
              child: Container(
                color: Colors.white, // Dropdown arka planı beyaz
                child: DropdownButtonFormField<String>(
                  value: value,
                  items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}