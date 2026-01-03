import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/firestore_service.dart';
import '../providers/project_provider.dart';
import 'cutting_list_screen.dart'; 
import 'module_add_screen.dart'; // <-- Bunu eklemeyi unutma

class SavedProjectsScreen extends StatelessWidget {
  const SavedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final FirestoreService firestoreService = FirestoreService();

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Lütfen önce giriş yapın.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Kayıtlı Projelerim")),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getProjectsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Hata: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Henüz kayıtlı projeniz yok.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final projectId = doc.id;

              String dateStr = "-";
              if (data['date'] != null) {
                try {
                  DateTime parsedDate = DateTime.parse(data['date']);
                  dateStr = DateFormat('dd.MM.yyyy HH:mm').format(parsedDate);
                } catch (e) {
                  dateStr = "Tarih Hatası";
                }
              }

              final projectName = data['name'] ?? "İsimsiz Proje";
              final totalCost = (data['totalCost'] ?? 0).toStringAsFixed(2);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // İç boşluk ayarı
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text(
                      projectName.isNotEmpty ? projectName[0].toUpperCase() : "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(projectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Tarih: $dateStr\nTutar: $totalCost TL"),
                  isThreeLine: true,
                  
                  // --- DEĞİŞİKLİK BURADA BAŞLIYOR ---
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // <--- BU KOD BUTONLARIN GÖRÜNMESİNİ SAĞLAR
                    children: [
                      // 1. GÜNCELLEME (DÜZENLEME) BUTONU
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: "Projeyi Düzenle",
                        onPressed: () {
                          _openProject(context, data, projectId, projectName);
                        },
                      ),
                      
                      // 2. SİLME BUTONU
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: "Projeyi Sil",
                        onPressed: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Projeyi Sil"),
                              content: const Text("Bu proje kalıcı olarak silinecek. Emin misiniz?"),
                              actions: [
                                TextButton(
                                  child: const Text("İptal", style: TextStyle(color: Colors.grey)),
                                  onPressed: () => Navigator.pop(ctx, false),
                                ),
                                TextButton(
                                  child: const Text("Sil", style: TextStyle(color: Colors.red)),
                                  onPressed: () => Navigator.pop(ctx, true),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await firestoreService.deleteProject(userId, projectId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Proje silindi.")),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  // --- DEĞİŞİKLİK BURADA BİTİYOR ---

                  // Satıra tıklanınca da projeyi açsın (Kullanıcı dostu özellik)
                  onTap: () {
                    _openProject(context, data, projectId, projectName);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- PROJE AÇMA FONKSİYONU ---
  // Kod tekrarını önlemek için dışarı aldık. Hem "Kalem" butonunda hem "Satır" tıklamasında çalışır.// --- PROJE AÇMA FONKSİYONU ---
 // saved_projects_screen.dart içindeki _openProject fonksiyonu:

  void _openProject(BuildContext context, Map<String, dynamic> data, String projectId, String projectName) {
    // 1. Verileri Provider'a yükle
    context.read<ProjectProvider>().loadProjectFromFirebase(data, projectId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'$projectName' düzenleme modunda açıldı."),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );

    // 2. Modül Ekleme Ekranına git ama LİSTE sekmesini açtır
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ModuleAddScreen(initialTabIndex: 1), // <--- BURAYA 1 YAZDIK (Liste Sekmesi)
      ), 
    );
  }
}