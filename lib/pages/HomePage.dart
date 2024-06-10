import 'package:dizigurmesi/pages/FavoritesPage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Category.dart';
import 'Search.dart';
import 'Profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> diziler = [];
  List<Map<String, dynamic>> top10Diziler = [];
  List<Map<String, dynamic>> trendDiziler = [];
  List<Map<String, dynamic>> yerlidiziler = [];
  bool isLoading = true;
  bool isTop10Loading = true;
  bool isTrendLoading = true;
  bool isYerliLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDiziler();
    fetchTop10Diziler();
    fetchTrendDiziler();
    fetchYerliDiziler();
  }

  Future<void> fetchDiziler() async {
    try {
      final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('diziler').get();
      final List<DocumentSnapshot> documents = result.docs;
      setState(() {
        diziler = documents.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['dizioyunculari'] = (data['dizioyunculari'] is List)
              ? data['dizioyunculari']
              : (data['dizioyunculari'] as String)
                  .split(', ')
                  .map((e) => e.trim())
                  .toList();
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Veri çekme hatası: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTop10Diziler() async {
    try {
      final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('top10Diziler').get();
      final List<DocumentSnapshot> documents = result.docs;
      setState(() {
        top10Diziler = documents.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['dizioyunculari'] = (data['dizioyunculari'] is List)
              ? data['dizioyunculari']
              : (data['dizioyunculari'] as String)
                  .split(', ')
                  .map((e) => e.trim())
                  .toList();
          return data;
        }).toList();
        isTop10Loading = false;
      });
    } catch (e) {
      print("Top 10 diziler veri çekme hatası: $e");
      setState(() {
        isTop10Loading = false;
      });
    }
  }

  Future<void> fetchTrendDiziler() async {
    try {
      final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('trendDiziler').get();
      final List<DocumentSnapshot> documents = result.docs;
      setState(() {
        trendDiziler = documents.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['dizioyunculari'] = (data['dizioyunculari'] is List)
              ? data['dizioyunculari']
              : (data['dizioyunculari'] as String)
                  .split(', ')
                  .map((e) => e.trim())
                  .toList();
          return data;
        }).toList();
        isTrendLoading = false;
      });
    } catch (e) {
      print("Trend diziler veri çekme hatası: $e");
      setState(() {
        isTrendLoading = false;
      });
    }
  }

  Future<void> fetchYerliDiziler() async {
    try {
      final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('yerlidiziler').get();
      final List<DocumentSnapshot> documents = result.docs;
      setState(() {
        yerlidiziler = documents.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['dizioyunculari'] = (data['dizioyunculari'] is List)
              ? data['dizioyunculari']
              : (data['dizioyunculari'] as String)
                  .split(', ')
                  .map((e) => e.trim())
                  .toList();
          return data;
        }).toList();
        isYerliLoading = false;
      });
    } catch (e) {
      print("Yerli diziler veri çekme hatası: $e");
      setState(() {
        isYerliLoading = false;
      });
    }
  }

  void _showDiziDetails(Map<String, dynamic> dizi) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dizi['diziadi'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Image.network(dizi['dizifotosu']),
                SizedBox(height: 10),
                Text("Çıkış Tarihi: ${dizi['dizicikistarihi']}"),
                SizedBox(height: 10),
                Text("Kategori: ${dizi['dizikategori']}"),
                SizedBox(height: 10),
                Text("Puan: ${dizi['dizipuanı']}"),
                SizedBox(height: 10),
                Text("Oyuncular: ${dizi['dizioyunculari'].join(', ')}"),
                SizedBox(height: 10),
                Text("Yönetmen: ${dizi['diziyönetmeni']}"),
                SizedBox(height: 10),
                Text("Açıklama: ${dizi['diziaciklamasi']}"),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      addToFavorites(dizi['diziadi']);
                    },
                    child: Text("Favorilere Ekle"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> addToFavorites(String diziName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final DocumentReference favoriteRef =
            FirebaseFirestore.instance.collection('favoriler').doc(userId);

        await favoriteRef.update({
          'favoriDiziler': FieldValue.arrayUnion([diziName])
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$diziName favorilere eklendi!"),
          ),
        );
      }
    } catch (e) {
      print("Favorilere ekleme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              'lib/assets/images/logo.png',
              width: 220,
              height: 150,
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (diziler.isNotEmpty)
            CarouselSlider(
              items: diziler.map((dizi) {
                return GestureDetector(
                  onTap: () => _showDiziDetails(dizi),
                  child: Container(
                    child: Column(
                      children: [
                        Image.network(dizi['dizifotosu']),
                        SizedBox(height: 10),
                        Text(
                          dizi['diziadi'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                autoPlay: true,
              ),
            )
          else
            Center(child: Text("Gösterilecek dizi yok.")),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Top 10 Diziler",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (isTop10Loading)
            Center(child: CircularProgressIndicator())
          else if (top10Diziler.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: top10Diziler.map((dizi) {
                  return GestureDetector(
                    onTap: () => _showDiziDetails(dizi),
                    child: Container(
                      width: 150,
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Image.network(dizi['dizifotosu']),
                          SizedBox(height: 10),
                          Text(
                            dizi['diziadi'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Center(child: Text("Gösterilecek top 10 dizi yok.")),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Trend Diziler",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (isTrendLoading)
            Center(child: CircularProgressIndicator())
          else if (trendDiziler.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: trendDiziler.map((dizi) {
                  return GestureDetector(
                    onTap: () => _showDiziDetails(dizi),
                    child: Container(
                      width: 150,
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Image.network(dizi['dizifotosu']),
                          SizedBox(height: 10),
                          Text(
                            dizi['diziadi'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Center(child: Text("Gösterilecek trend dizi yok.")),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Yerli Diziler",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (isYerliLoading)
            Center(child: CircularProgressIndicator())
          else if (yerlidiziler.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: yerlidiziler.map((dizi) {
                  return GestureDetector(
                    onTap: () => _showDiziDetails(dizi),
                    child: Container(
                      width: 150,
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Image.network(dizi['dizifotosu']),
                          SizedBox(height: 10),
                          Text(
                            dizi['diziadi'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Center(child: Text("Gösterilecek yerli dizi yok.")),
        ],
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
