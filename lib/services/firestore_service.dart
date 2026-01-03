import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. PROJEYİ KAYDETME ---
  Future<void> saveProject({
    required String userId,
    required String projectName,
    required List<Map<String, dynamic>> modules,
    required double totalCost,
  }) async {
    try {
      await _db.collection('users').doc(userId).collection('projects').add({
        'name': projectName, // UI tarafı 'name' bekliyor
        'date': DateTime.now().toIso8601String(), // UI String tarih bekliyor
        'totalCost': totalCost,
        'modules': modules,
      });
    } catch (e) {
      print("Firestore Hatası: $e");
      throw e;
    }
  }

  // --- 2. PROJELERİ GETİRME (STREAM) ---
  // HATAYI ÇÖZEN KISIM: Fonksiyon adını UI ile aynı (getProjectsStream) yaptık
  Stream<QuerySnapshot> getProjectsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .orderBy('date', descending: true) // Tarihe göre sırala
        .snapshots();
  }
  
  // --- 3. PROJE SİLME ---
  Future<void> deleteProject(String userId, String projectId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(projectId)
          .delete();
    } catch (e) {
      print("Silme Hatası: $e");
      throw e;
    }
  }

  // --- 4. PROJE GÜNCELLEME ---
  Future<void> updateProject({
    required String userId,
    required String projectId,
    required String projectName,
    required List<Map<String, dynamic>> modules,
    required double totalCost,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(projectId)
          .update({
        'name': projectName,
        'date': DateTime.now().toIso8601String(),
        'totalCost': totalCost,
        'modules': modules,
      });
    } catch (e) {
      print("Güncelleme Hatası: $e");
      throw e;
    }
  }
}