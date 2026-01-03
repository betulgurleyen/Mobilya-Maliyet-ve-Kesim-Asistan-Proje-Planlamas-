import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import 'cutting_list_screen.dart';

class ModuleAddScreen extends StatefulWidget {
  // --- DEĞİŞİKLİK 1: Dışarıdan sekme numarası alıyoruz ---
  final int initialTabIndex; 

  const ModuleAddScreen({
    super.key, 
    this.initialTabIndex = 0 // Varsayılan 0 (Form), istenirse 1 (Liste) olur.
  });

  @override
  State<ModuleAddScreen> createState() => _ModuleAddScreenState();
}

class _ModuleAddScreenState extends State<ModuleAddScreen>
    with SingleTickerProviderStateMixin {
  // --- TEMEL KONTROLCÜLER ---
  final wCtrl = TextEditingController();
  final hCtrl = TextEditingController();
  final dCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: "1");
  final shelfCtrl = TextEditingController();
  final coverCtrl = TextEditingController();

  // Ek Parça ve Diğerleri
  final extraPartNameCtrl = TextEditingController();
  final fridgePostCountCtrl = TextEditingController();
  final fridgePostDepthCtrl = TextEditingController();

  // --- MANUEL GİRİŞ İÇİN LİSTELER ---
  List<TextEditingController> _manualWidths = [];
  List<TextEditingController> _manualHeights = [];

  // --- SEÇİMLER (DROPDOWN) ---
  String selectedType = "Alt Dolap";
  String _selectedCoverMode = "Eşit";
  String _selectedMaterial = "Gövde";
  String _selectedHandleType = "Normal";
  String _selectedRayType = "Beyaz";
  String _selectedDrawerConfig = "3 Eşit";
  String _selectedTacModel = "Taçsız";
  String _selectedMicrowave = "Yok";
  String _selectedTopPanel = "Yok";

  String? _selectedModuleId;

  late TabController _tabController;

  final List<String> _moduleTypes = [
    "Alt Dolap",
    "Üst Dolap",
    "Boy Dolap",
    "Davlumbaz",
    "Makine Dolabı (Kapaksız)",
    "Makine Dolabı (Kapaklı)",
    "Buzdolabı",
    "Çekmece (Serbest)",
    "Çekmece",
    "Fırın + Çekmece",
    "Ankastre Boy",
    "Ek Parça"
  ];

  @override
  void initState() {
    super.initState();
    // --- DEĞİŞİKLİK 2: TabController'a başlangıç indeksini veriyoruz ---
    _tabController = TabController(
      length: 2, 
      vsync: this, 
      initialIndex: widget.initialTabIndex // <--- BURASI EKLENDİ
    );
    
    coverCtrl.addListener(_updateManualControllers);
  }

  @override
  void dispose() {
    wCtrl.dispose();
    hCtrl.dispose();
    dCtrl.dispose();
    qtyCtrl.dispose();
    shelfCtrl.dispose();
    coverCtrl.dispose();
    extraPartNameCtrl.dispose();
    fridgePostCountCtrl.dispose();
    fridgePostDepthCtrl.dispose();
    for (var c in _manualWidths) c.dispose();
    for (var c in _manualHeights) c.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateManualControllers() {
    if (_selectedCoverMode != "Manuel") return;
    int count = int.tryParse(coverCtrl.text) ?? 0;
    if (count > 20) count = 20;
    if (_manualWidths.length != count) {
      setState(() {
        _manualWidths.clear();
        _manualHeights.clear();
        for (int i = 0; i < count; i++) {
          _manualWidths.add(TextEditingController());
          _manualHeights.add(TextEditingController());
        }
      });
    }
  }

  // --- FORM DOLDURMA (DÜZENLEME İÇİN) ---
  void _populateFormForEdit(Map<String, dynamic> mod) {
    setState(() {
      _selectedModuleId = mod['id'];

      selectedType = mod['type'];
      qtyCtrl.text = mod['quantity'].toString();
      wCtrl.text = mod['width'].toString();
      hCtrl.text = mod['height'].toString();
      dCtrl.text = mod['depth'].toString();

      shelfCtrl.text = (mod['shelfCount'] ?? 0).toString();
      coverCtrl.text = (mod['coverCount'] ?? 0).toString();

      _selectedHandleType = mod['handleType'] ?? "Normal";
      _selectedRayType = mod['rayType'] ?? "Beyaz";
      _selectedCoverMode = (mod['coverEqual'] == false) ? "Manuel" : "Eşit";
      _selectedDrawerConfig = mod['drawerConfig'] ?? "3 Eşit";

      _selectedMicrowave = (mod['hasMicrowave'] == true) ? "Var" : "Yok";
      _selectedTopPanel = (mod['hasTopPanel'] == true) ? "Var" : "Yok";
      _selectedTacModel = (mod['isTacli'] == true) ? "Taçlı" : "Taçsız";

      fridgePostCountCtrl.text = (mod['fridgePostCount'] ?? 0).toString();
      fridgePostDepthCtrl.text = (mod['fridgePostDepth'] ?? 0).toString();

      extraPartNameCtrl.text = mod['extraPartName'] ?? "";
      _selectedMaterial = mod['extraMaterial'] ?? "Gövde";

      if (_selectedCoverMode == "Manuel") {
        _updateManualControllers();
        List<dynamic> mw = mod['manualWidths'] ?? [];
        List<dynamic> mh = mod['manualHeights'] ?? [];
        for (int i = 0; i < _manualWidths.length; i++) {
          if (i < mw.length) _manualWidths[i].text = mw[i].toString();
          if (i < mh.length) _manualHeights[i].text = mh[i].toString();
        }
      }
    });

    // Düzenle'ye basınca Form sekmesine geç
    _tabController.animateTo(0);
  }

  // --- EKLE VEYA GÜNCELLE ---
  void _handleSave() {
    if (selectedType != "Ek Parça" &&
        (wCtrl.text.isEmpty || hCtrl.text.isEmpty || dCtrl.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen ölçüleri giriniz.")));
      return;
    }

    if (_selectedModuleId != null) {
      context.read<ProjectProvider>().removeModuleById(_selectedModuleId!);
    }

    List<double> collectedWidths = [];
    List<double> collectedHeights = [];
    if (_selectedCoverMode == "Manuel") {
      for (var c in _manualWidths)
        collectedWidths.add(double.tryParse(c.text) ?? 0);
      for (var c in _manualHeights)
        collectedHeights.add(double.tryParse(c.text) ?? 0);
    }

    context.read<ProjectProvider>().addModule(
          type: selectedType,
          quantity: int.tryParse(qtyCtrl.text) ?? 1,
          width: double.tryParse(wCtrl.text) ?? 0,
          height: double.tryParse(hCtrl.text) ?? 0,
          depth: double.tryParse(dCtrl.text) ?? 0,
          shelfCount: int.tryParse(shelfCtrl.text) ?? 0,
          coverCount: int.tryParse(coverCtrl.text) ?? 0,
          coverEqual: _selectedCoverMode == "Eşit",
          handleType: _selectedHandleType,
          rayType: _selectedRayType,
          drawerConfig: _selectedDrawerConfig,
          hasMicrowave: _selectedMicrowave == "Var",
          hasTopPanel: _selectedTopPanel == "Var",
          isTacli: _selectedTacModel == "Taçlı",
          fridgePostCount: int.tryParse(fridgePostCountCtrl.text) ?? 0,
          fridgePostDepth: double.tryParse(fridgePostDepthCtrl.text) ?? 0,
          extraPartName: extraPartNameCtrl.text,
          extraMaterial: _selectedMaterial,
          manualWidths: collectedWidths.isNotEmpty ? collectedWidths : null,
          manualHeights: collectedHeights.isNotEmpty ? collectedHeights : null,
        );

    String msg = _selectedModuleId != null
        ? "Modül Güncellendi ✅"
        : "$selectedType Eklendi ✅";
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));

    _clearForm();
    // Kaydettikten sonra listeye geçmek istersen şu yorum satırını açabilirsin:
    _tabController.animateTo(1);
  }

  void _clearForm() {
    setState(() {
      _selectedModuleId = null;
      wCtrl.clear();
      hCtrl.clear();
      dCtrl.clear();
      qtyCtrl.text = "1";
      shelfCtrl.clear();
      coverCtrl.clear();
      fridgePostCountCtrl.clear();
      fridgePostDepthCtrl.clear();
      extraPartNameCtrl.clear();
      _selectedCoverMode = "Eşit";
      _manualWidths.clear();
      _manualHeights.clear();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modül Sihirbazı"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_box), text: "Form"),
            Tab(icon: Icon(Icons.list), text: "Liste"),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.calculate, color: Colors.black),
            label: const Text("Kesim Listesi",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CuttingListScreen())),
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- SEKME 1: FORM ---
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("MODÜL ÖZELLİKLERİ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey)),
                        const Divider(),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          isExpanded: true,
                          items: _moduleTypes
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            selectedType = v!;
                            _clearForm();
                            selectedType = v;
                          }),
                          decoration: const InputDecoration(
                              labelText: "Modül Türü",
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        _buildInputRow("Adet:", qtyCtrl),
                        const SizedBox(height: 10),
                        _buildFormFields(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // BUTONLAR
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton.icon(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedModuleId != null
                              ? Colors.orange
                              : Colors.blueGrey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      icon: Icon(_selectedModuleId != null
                          ? Icons.edit
                          : Icons.add_circle),
                      label: Text(
                          _selectedModuleId != null
                              ? "GÜNCELLE"
                              : "LİSTEYE EKLE",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    )),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: _clearForm,
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        tooltip: "Formu Temizle")
                  ],
                )
              ],
            ),
          ),

          // --- SEKME 2: LİSTE ---
          Container(
            color: Colors.white,
            child: Consumer<ProjectProvider>(
              builder: (context, provider, child) {
                // 1. Veriyi Temiz Bir Şekilde Ayıralım
                final extraParts = provider.addedModules
                    .where((m) => m['type'] == 'Ek Parça')
                    .toList();

                final standardModules = provider.addedModules
                    .where((m) => m['type'] != 'Ek Parça')
                    .toList();

                // Liste tamamen boşsa uyarı göster
                if (provider.addedModules.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz hiçbir kayıt eklenmedi.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                // 2. Scroll Yapısı
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- TABLO 1: ANA MODÜLLER ---
                      if (standardModules.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: Colors.blueGrey.shade100,
                          child: const Text(
                            "EKLENEN MODÜLLER",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                                Colors.blueGrey.shade50),
                            columnSpacing: 20,
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
                            columns: const [
                              DataColumn(label: Text("İşlem")),
                              DataColumn(label: Text("Tür")),
                              DataColumn(label: Text("Adet"), numeric: true),
                              DataColumn(label: Text("En")),
                              DataColumn(label: Text("Boy")),
                              DataColumn(label: Text("Derinlik")),
                              DataColumn(label: Text("Detaylar")),
                            ],
                            rows: standardModules.map((mod) {
                              bool isEditing = mod['id'] == _selectedModuleId;
                              return DataRow(
                                selected: isEditing,
                                color: WidgetStateProperty.resolveWith<Color?>(
                                    (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.orange.withOpacity(0.2);
                                  }
                                  return null;
                                }),
                                cells: [
                                  _buildActionCell(
                                      context, provider, mod), 
                                  DataCell(Text(mod['type'] ?? "")),
                                  DataCell(Text(mod['quantity'].toString())),
                                  DataCell(Text(mod['width'].toString())),
                                  DataCell(Text(mod['height'].toString())),
                                  DataCell(Text(mod['depth'].toString())),
                                  DataCell(
                                    Container(
                                      constraints:
                                          const BoxConstraints(maxWidth: 150),
                                      child: Text(
                                        _generateDetailText(mod),
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20), 
                      ],

                      // --- TABLO 2: EKSTRA PARÇALAR ---
                      if (extraParts.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: Colors.orange.shade100,
                          child: const Text(
                            "EKSTRA PARÇALAR",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(Colors.orange.shade50),
                            columnSpacing: 30,
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
                            columns: const [
                              DataColumn(
                                  label:
                                      Text("Ekstra")),
                              DataColumn(label: Text("Parça Türü")),
                              DataColumn(label: Text("En")),
                              DataColumn(label: Text("Boy")),
                              DataColumn(label: Text("Malzeme")),
                            ],
                            rows: extraParts.map((mod) {
                              bool isEditing = mod['id'] == _selectedModuleId;
                              return DataRow(
                                selected: isEditing,
                                color: WidgetStateProperty.resolveWith<Color?>(
                                    (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.orange.withOpacity(0.2);
                                  }
                                  return null;
                                }),
                                cells: [
                                  _buildActionCell(context, provider, mod),
                                  DataCell(Text(
                                      mod['extraPartName'] ?? "Tanımsız",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500))),
                                  DataCell(Text(mod['width'].toString())),
                                  DataCell(Text(mod['height'].toString())),
                                  DataCell(Text(mod['extraMaterial'] ?? "-")),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
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

  DataCell _buildActionCell(BuildContext context, ProjectProvider provider,
      Map<String, dynamic> mod) {
    return DataCell(Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
          onPressed: () => _populateFormForEdit(mod),
          tooltip: "Düzenle",
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () {
            provider.removeModuleById(mod['id']);
            if (_selectedModuleId == mod['id']) _clearForm();
          },
          tooltip: "Sil",
        ),
      ],
    ));
  }

  // --- YARDIMCI WIDGETLAR ---
  Widget _buildFormFields() {
    if (selectedType == "Ek Parça") {
      if (_selectedMaterial != "Gövde" && _selectedMaterial != "Kapak")
        _selectedMaterial = "Gövde";
      return Column(children: [
        _buildInputRow("Parça Adı:", extraPartNameCtrl, hint: "Yan Panel"),
        _buildInputRow("En (cm):", wCtrl),
        _buildInputRow("Boy (cm):", hCtrl),
        _buildDropdownRow("Malzeme:", _selectedMaterial, ["Gövde", "Kapak"],
            (v) => setState(() => _selectedMaterial = v!)),
      ]);
    }
    if (selectedType == "Makine Dolabı (Kapaksız)") {
      return Column(children: [
        _buildInputRow("Genişlik:", wCtrl),
        _buildInputRow("Derinlik:", dCtrl),
        _buildInputRow("Yükseklik:", hCtrl)
      ]);
    }

    List<Widget> fields = [];
    fields.add(_buildInputRow("Genişlik:", wCtrl));
    fields.add(_buildInputRow("Derinlik:", dCtrl));
    fields.add(_buildInputRow("Yükseklik:", hCtrl));

    if (selectedType == "Buzdolabı") {
      fields.add(_buildInputRow("Dikme Sayısı:", fridgePostCountCtrl));
      fields.add(_buildInputRow("Dikme Derinliği:", fridgePostDepthCtrl));
      fields.add(_buildDropdownRow("Taç Modeli:", _selectedTacModel,
          ["Taçlı", "Taçsız"], (v) => _selectedTacModel = v!));
      return Column(children: fields);
    }
    if (selectedType != "Davlumbaz") {
      fields.add(_buildInputRow("Kapak Sayısı:", coverCtrl));
      fields.add(_buildDropdownRow(
          "Kapak Tipi:", _selectedCoverMode, ["Eşit", "Manuel"], (v) {
        setState(() {
          _selectedCoverMode = v!;
          _updateManualControllers();
        });
      }));
      if (_selectedCoverMode == "Manuel") {
        fields.add(Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(5)),
            child: _manualWidths.isEmpty
                ? const Text("Kapak sayısı giriniz.",
                    style: TextStyle(color: Colors.red, fontSize: 12))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _manualWidths.length,
                    itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(children: [
                          Text("${index + 1}.Kapak:",
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 5),
                          Expanded(
                              child: _buildCompactInput(
                                  _manualWidths[index], "En")),
                          const SizedBox(width: 5),
                          Expanded(
                              child: _buildCompactInput(
                                  _manualHeights[index], "Boy")),
                        ])))));
      }
    }

    if (selectedType == "Çekmece")
      fields.add(_buildDropdownRow(
          "Çekmece Tipi:",
          _selectedDrawerConfig,
          ["2 Sığ 1 Derin", "3 Eşit", "4 Eşit"],
          (v) => _selectedDrawerConfig = v!));
    if (!selectedType.contains("Çekmece") && selectedType != "Davlumbaz")
      fields.add(_buildInputRow("Raf Sayısı:", shelfCtrl));
    fields.add(_buildDropdownRow("Kulp Tipi:", _selectedHandleType,
        ["Normal", "Gizli"], (v) => _selectedHandleType = v!));
    if (selectedType.contains("Çekmece") ||
        selectedType.contains("Ankastre") ||
        selectedType.contains("Fırın")) {
      fields.add(_buildDropdownRow("Ray Türü:", _selectedRayType,
          ["Beyaz", "Teleskopik", "Smart"], (v) => _selectedRayType = v!));
    }
    return Column(children: fields);
  }

  Widget _buildInputRow(String label, TextEditingController ctrl,
      {String? hint}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
          Expanded(
              flex: 3,
              child: SizedBox(
                  height: 35,
                  child: TextFormField(
                      controller: ctrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: hint,
                          border: const OutlineInputBorder(),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10)))))
        ]));
  }

  Widget _buildDropdownRow(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
          Expanded(
              flex: 3,
              child: SizedBox(
                  height: 35,
                  child: DropdownButtonFormField<String>(
                      value: value,
                      items: items
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10)))))
        ]));
  }

  Widget _buildCompactInput(TextEditingController ctrl, String hint) {
    return SizedBox(
        height: 30,
        child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: hint,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                border: const OutlineInputBorder())));
  }

  // --- TEMİZ KOD İÇİN YARDIMCI METOT ---
  String _generateDetailText(Map<String, dynamic> mod) {
    List<String> parts = [];
    String type = mod['type'] ?? "";

    // 1. Ek Parça Özel Durumu
    if (type == "Ek Parça") {
      parts.add(mod['extraMaterial'] ?? "");
      if (mod['extraPartName'] != null &&
          mod['extraPartName'].toString().isNotEmpty) {
        parts.add("(${mod['extraPartName']})");
      }
      return parts.join(" ");
    }

    // 2. Kapak Bilgisi
    int coverCount = mod['coverCount'] ?? 0;
    if (coverCount > 0) {
      String coverInfo = "$coverCount Kapak";
      if (mod['coverEqual'] == false) coverInfo += " (Manuel)";
      parts.add(coverInfo);
    }

    // 3. Raf Bilgisi
    int shelfCount = mod['shelfCount'] ?? 0;
    if (shelfCount > 0) {
      parts.add("$shelfCount Raf");
    }

    // 4. Çekmece Detayı
    if (type.contains("Çekmece") && mod['drawerConfig'] != null) {
      parts.add(mod['drawerConfig']);
    }

    // 5. Kulp 
    String handle = mod['handleType'] ?? "Normal";
    if (handle != "Normal") {
      parts.add("$handle Kulp");
    }

    // 6. Ray Tipi 
    String ray = mod['rayType'] ?? "Beyaz";
    if ((type.contains("Çekmece") || type.contains("Ankastre")) &&
        ray != "Beyaz") {
      parts.add("$ray Ray");
    }

    // 7. Diğer Özellikler
    if (mod['isTacli'] == true) parts.add("Taçlı");
    if (mod['hasMicrowave'] == true) parts.add("Mikrodalga Modüllü");

    if (parts.isEmpty) return "-";
    return parts.join(", ");
  }
}