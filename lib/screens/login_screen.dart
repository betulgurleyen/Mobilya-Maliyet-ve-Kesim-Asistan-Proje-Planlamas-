import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form kontrolü için anahtar
  final _formKey = GlobalKey<FormState>();
  
  // Girdi verilerini tutanlar
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Mod kontrolü: True ise Giriş Ekranı, False ise Kayıt Ekranı
  bool _isLoginMode = true; 

  // İşlemleri yapan fonksiyon
  void _submitAuthForm() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final usersBox = Hive.box('users');

    if (_isLoginMode) {
      // --- GİRİŞ YAPMA MANTIĞI ---
      if (usersBox.containsKey(email)) {
        // Kullanıcı var, şifreyi kontrol et
        final storedPassword = usersBox.get(email);
        if (storedPassword == password) {
          // Giriş Başarılı -> Ana Sayfaya Git
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Giriş Başarılı!"), backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          _showError("Şifre hatalı!");
        }
      } else {
        _showError("Bu e-posta ile kayıtlı kullanıcı bulunamadı.");
      }
    } else {
      // --- KAYIT OLMA MANTIĞI ---
      if (usersBox.containsKey(email)) {
        _showError("Bu e-posta adresi zaten kullanılıyor.");
      } else {
        // Yeni kullanıcıyı kaydet (Anahtar: email, Değer: şifre)
        usersBox.put(email, password);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hesap oluşturuldu! Şimdi giriş yapabilirsiniz."), backgroundColor: Colors.green),
        );
        
        // Kayıttan sonra giriş moduna dön
        setState(() {
          _isLoginMode = true;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ve Başlık
                const Icon(Icons.chair_rounded, size: 80, color: Colors.blueGrey),
                const SizedBox(height: 10),
                const Text("Mobilya Asistanı", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 40),
                
                // Sayfa Başlığı (Giriş Yap / Kayıt Ol)
                Text(
                  _isLoginMode ? "Giriş Yap" : "Hesap Oluştur",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // E-posta Alanı
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "E-Posta Adresi",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Geçerli bir e-posta giriniz.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Şifre Alanı
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Şifreyi gizle
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Ana Buton (Giriş Yap / Kayıt Ol)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitAuthForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _isLoginMode ? "Giriş Yap" : "Kayıt Ol",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Mod Değiştirme Linki
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode; // Modu tersine çevir
                      _formKey.currentState?.reset(); // Hata mesajlarını temizle
                    });
                  },
                  child: Text(
                    _isLoginMode 
                      ? "Hesabın yok mu? Hesap Oluştur" 
                      : "Zaten hesabın var mı? Giriş Yap",
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}