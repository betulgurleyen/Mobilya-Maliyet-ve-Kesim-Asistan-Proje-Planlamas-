import 'dart:io';
// import 'package:flutter/services.dart'; // Gerekirse açarsın
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/cutting_part.dart';

class ExportService {
  
  // --- PDF OLUŞTUR VE GÖSTER ---
  Future<void> exportToPdf(String projectName, List<Map<String, dynamic>> modules, List<CuttingPart> allParts) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text("PROJE: $projectName", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),
            
            ...modules.map((mod) {
              final modParts = allParts.where((p) => p.moduleId == mod['id']).toList();
              
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    color: PdfColors.grey300,
                    width: double.infinity,
                    child: pw.Text(
                      "${mod['type']} (${mod['width']}x${mod['height']}x${mod['depth']}) - Adet: ${mod['quantity']}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                    )
                  ),
                  pw.Table.fromTextArray(
                    context: context,
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    cellStyle: const pw.TextStyle(fontSize: 10),
                    headers: ['Parca Adi', 'Adet', 'En (cm)', 'Boy (cm)', 'Malzeme'],
                    data: modParts.map((p) => [
                      p.name,
                      p.quantity.toString(),
                      p.width.toString(),
                      p.length.toString(),
                      p.material
                    ]).toList(),
                  ),
                  pw.SizedBox(height: 15),
                ]
              );
            }).toList()
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '${projectName}_KesimListesi',
    );
  }

  // --- EXCEL OLUŞTUR VE PAYLAŞ ---
  Future<void> exportToExcel(String projectName, List<Map<String, dynamic>> modules, List<CuttingPart> allParts) async {
    var excel = Excel.createExcel();
    
    // Varsayılan sayfa adını değiştirebilir veya 'Sheet1' kullanabilirsin
    Sheet sheetObject = excel['Kesim Listesi'];
    
    // Başlık Stili (ExcelColor kullanımı değişti)
    CellStyle headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString("#CCCCCC"), // DÜZELTME 1: ExcelColor objesi
      fontFamily : getFontFamily(FontFamily.Calibri),
      bold: true,
    );

    // 1. Satır: Başlıklar (CellValue kullanımı değişti)
    // DÜZELTME 2: String yerine TextCellValue kullanıyoruz
    List<CellValue> headers = [
      TextCellValue("Modül"),
      TextCellValue("Parça Adı"),
      TextCellValue("Adet"),
      TextCellValue("En (cm)"),
      TextCellValue("Boy (cm)"),
      TextCellValue("Malzeme"),
      TextCellValue("Alan (m2)")
    ];
    
    sheetObject.appendRow(headers);

    // Verileri Doldur
    for (var mod in modules) {
      final modParts = allParts.where((p) => p.moduleId == mod['id']).toList();
      
      for (var p in modParts) {
        // DÜZELTME 3: Veri türüne göre Int, Double veya Text CellValue kullanıyoruz
        sheetObject.appendRow([
          TextCellValue(mod['type'].toString()),    // String
          TextCellValue(p.name),                    // String
          IntCellValue(p.quantity),                 // int
          DoubleCellValue(p.width),                 // double
          DoubleCellValue(p.length),                // double
          TextCellValue(p.material),                // String
          DoubleCellValue(p.area),                  // double
        ]);
      }
    }

    // Dosyayı Kaydet
    var fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      // Dosya adını temizle (boşluk varsa vs)
      final safeName = projectName.replaceAll(" ", "_");
      final path = "${directory.path}/$safeName.xlsx";
      
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      
      // Paylaşım penceresini aç
      await Share.shareXFiles([XFile(path)], text: '$projectName Excel Dosyası');
    }
  }
}