import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';
import 'Category.dart';
import 'Search.dart';
import 'Profile.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> favoriteDiziNames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoriteDiziler();
  }

  Future<void> fetchFavoriteDiziler() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final DocumentSnapshot result = await FirebaseFirestore.instance
            .collection('favoriler')
            .doc(userId)
            .get();

        setState(() {
          favoriteDiziNames =
              List<String>.from(result['favoriDiziler'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Favori diziler veri çekme hatası: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> removeFromFavorites(String diziName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final DocumentReference favoriteRef = FirebaseFirestore.instance
            .collection('favoriler')
            .doc(userId);

        await favoriteRef.update({
          'favoriDiziler': FieldValue.arrayRemove([diziName])
        });

        setState(() {
          favoriteDiziNames.remove(diziName);
        });
      }
    } catch (e) {
      print("Favoriden kaldırma hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favori Dizilerim'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteDiziNames.isEmpty
              ? Center(child: Text("Favori diziniz yok."))
              : ListView.builder(
                  itemCount: favoriteDiziNames.length,
                  itemBuilder: (context, index) {
                    final diziName = favoriteDiziNames[index];
                    return ListTile(
                      title: Text(diziName),
                      trailing: IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () => removeFromFavorites(diziName),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.category),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Category()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Search()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
