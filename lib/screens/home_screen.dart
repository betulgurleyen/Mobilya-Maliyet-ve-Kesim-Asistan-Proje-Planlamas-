import 'package:flutter/material.dart';
import 'settings_screen.dart';

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
            // Eski projeler butonu (Şimdilik işlevsiz)
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open, size: 28),
              label: const Text("Eski Projeleri Gör", style: TextStyle(fontSize: 18)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Bu özellik yakında eklenecek!")),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
            const SizedBox(height: 30),
            
            // Yeni Proje Butonu
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle, size: 28),
              label: const Text("Yeni Proje Ekle", style: TextStyle(fontSize: 18)),
              onPressed: () {
                 // Doğrudan Ayarlar sayfasına yönlendiriyoruz
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
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