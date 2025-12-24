import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Hive eklendi
import 'providers/project_provider.dart';
import 'screens/login_screen.dart';

// lib/main.dart
void main() async {
  // Hive Başlatma
  await Hive.initFlutter();
  await Hive.openBox('app_settings'); // Ayarlar için
  await Hive.openBox('users');        // YENİ: Kullanıcılar için kutu açtık
  
  runApp(const MyApp());
}
// Kodun geri kalanı aynı...

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: MaterialApp(
        title: 'Mobilya Asistanı',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}