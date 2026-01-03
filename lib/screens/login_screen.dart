import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Kimlik Doğrulama
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoginMode = true; // True: Giriş Yap, False: Kayıt Ol
  bool _isLoading = false;  // Yükleniyor mu?

  // Firebase Auth Nesnesi
  final _auth = FirebaseAuth.instance;

  void _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Yükleniyor animasyonunu başlat

    try {
      if (_isLoginMode) {
        // --- GİRİŞ YAPMA İŞLEMİ ---
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giriş Başarılı!"), backgroundColor: Colors.green));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      
      } else {
        // --- KAYIT OLMA İŞLEMİ ---
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hesap Oluşturuldu! Giriş yapılıyor..."), backgroundColor: Colors.green));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      // Hata Mesajlarını Türkçeleştirme
      String message = "Bir hata oluştu.";
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') message = "Kullanıcı bulunamadı veya şifre yanlış.";
      if (e.code == 'wrong-password') message = "Şifre hatalı.";
      if (e.code == 'email-already-in-use') message = "Bu e-posta zaten kullanımda.";
      if (e.code == 'weak-password') message = "Şifre çok zayıf (en az 6 karakter olmalı).";
      if (e.code == 'invalid-email') message = "Geçersiz e-posta formatı.";
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false); // Yükleniyor animasyonunu durdur
    }
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
                const Icon(Icons.chair_rounded, size: 80, color: Colors.blueGrey),
                const SizedBox(height: 10),
                const Text("Mobilya Asistanı", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 40),
                
                Text(
                  _isLoginMode ? "Giriş Yap" : "Hesap Oluştur",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // E-posta
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "E-Posta", prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  validator: (val) => (val == null || !val.contains('@')) ? 'Geçerli bir e-posta giriniz.' : null,
                ),
                const SizedBox(height: 16),

                // Şifre
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Şifre", prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                  validator: (val) => (val == null || val.length < 6) ? 'Şifre en az 6 karakter olmalı.' : null,
                ),
                const SizedBox(height: 24),

                // Buton
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitAuthForm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(_isLoginMode ? "Giriş Yap" : "Kayıt Ol", style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 15),

                // Mod Değiştirme (Giriş <-> Kayıt)
                TextButton(
                  onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(
                    _isLoginMode ? "Hesabın yok mu? Hesap Oluştur" : "Zaten hesabın var mı? Giriş Yap",
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