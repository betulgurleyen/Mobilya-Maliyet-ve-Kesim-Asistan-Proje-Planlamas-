import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // EKLENDİ: Provider'a erişim için gerekli
import '../providers/project_provider.dart'; // EKLENDİ: ProjectProvider sınıfına erişim için
import 'settings_screen.dart';
import 'saved_projects_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Projelerim")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- ESKİ PROJELER BUTONU ---
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open, size: 28),
              label: const Text("Eski Projeleri Gör", style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const SavedProjectsScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- YENİ PROJE EKLE BUTONU ---
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle, size: 28),
              label: const Text("Yeni Proje Ekle", style: TextStyle(fontSize: 18)),
              onPressed: () {
                // 1. ADIM: Hafızadaki eski projeyi temizle
                // (Listen: false kullanıyoruz çünkü burada ekranı yenilemeye gerek yok, sadece fonksiyon çağırıyoruz)
                context.read<ProjectProvider>().clearProject();

                // 2. ADIM: Ayarlar sayfasına git
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const SettingsScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}