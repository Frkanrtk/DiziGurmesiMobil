import 'package:dizigurmesi/pages/Search.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomePage.dart';
import 'Profile.dart';
import 'FavoritesPage.dart';

class Category extends StatelessWidget {
  const Category({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          CategoryItem(icon: Icons.animation, title: 'Animasyon'),
          CategoryItem(icon: Icons.threed_rotation, title: '3 Boyutlu'),
          CategoryItem(icon: Icons.science, title: 'Bilim Kurgu'),
          CategoryItem(icon: Icons.family_restroom, title: 'Aile'),
          CategoryItem(icon: Icons.directions_run, title: 'Aksiyon'),
          CategoryItem(icon: Icons.person, title: 'Biyografi'),
          CategoryItem(icon: Icons.mood, title: 'Dram'),
          CategoryItem(icon: Icons.stars, title: 'Fantastik'),
          CategoryItem(icon: Icons.dangerous, title: 'Gerilim'),
          CategoryItem(icon: Icons.lock, title: 'Gizem'),
          CategoryItem(icon: Icons.mood, title: 'Komedi'),
          CategoryItem(icon: Icons.local_movies, title: 'Korku'),
          CategoryItem(icon: Icons.explore, title: 'Macera'),
          CategoryItem(icon: Icons.traffic, title: 'Savaş'),
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

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryItem({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(category: title),
          ),
        );
      },
    );
  }
}

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> diziler = [];
  List<Map<String, dynamic>> filteredDiziler = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    fetchDiziler();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchDiziler() async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('tumdiziler')
          .where('dizikategori', isEqualTo: widget.category)
          .get();
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
        filteredDiziler = List.from(diziler);
        isLoading = false;
      });
    } catch (e) {
      print("Veri çekme hatası: $e");
      setState(() {
        isLoading = false;
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
                Text("Puan: ${dizi['dizipuanı']}"),
                SizedBox(height: 10),
                Text("Oyuncular: ${dizi['dizioyunculari'].join(', ')}"),
                SizedBox(height: 10),
                Text("Yönetmen: ${dizi['diziyönetmeni']}"),
                SizedBox(height: 10),
                Text("Açıklama: ${dizi['diziaciklamasi']}"),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredDiziler = diziler.where((dizi) {
          return dizi['diziadi'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        filteredDiziler = List.from(diziler);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Kategorisi'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _performSearch,
                    decoration: InputDecoration(
                      hintText: 'Arama yapın...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _performSearch(_searchController.text);
                  },
                  child: Text(
                    'Ara',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: filteredDiziler.length,
                itemBuilder: (context, index) {
                  final dizi = filteredDiziler[index];
                  return GestureDetector(
                    onTap: () => _showDiziDetails(dizi),
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              dizi['dizifotosu'] ?? '',
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                              dizi['diziadi'] ?? 'Dizi Adı',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
