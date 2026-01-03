import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:hive_flutter/hive_flutter.dart';  
import 'firebase_options.dart';                    
import 'providers/project_provider.dart'; 
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 1. Hive Başlat (Ayarların silinmemesi için)
  await Hive.initFlutter();
  await Hive.openBox('app_settings'); 
  
  // 2. Firebase Başlat (Giriş işlemleri için)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 36, 70, 45)),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}