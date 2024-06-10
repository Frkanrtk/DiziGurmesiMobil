import 'package:dizigurmesi/pages/login_register_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginRegisterPage(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<void> _handleAddSeries() async {
    await addSeriesBatch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dizi Ekleme'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _handleAddSeries,
              child: Text('Dizileri Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> diziler = [
];

Future<void> addSeriesBatch() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  
  for (var dizi in diziler) {
    final docRef = firestore.collection('yerlidiziler').doc();
    batch.set(docRef, dizi);
  }

  await batch.commit();
  print("Diziler başarıyla Firestore'a eklendi.");
}
