import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(home: PlacesApp()));
}

class Place {
  String name;
  File? photo;
  Place({required this.name, this.photo});
}

class PlacesApp extends StatefulWidget {
  const PlacesApp({super.key});
  @override
  State<PlacesApp> createState() => _PlacesAppState();
}

class _PlacesAppState extends State<PlacesApp> {
  List<Place> miejsca = [
    Place(name: 'Park'),
    Place(name: 'Muzeum'),
    Place(name: 'Plaża'),
  ];

  int selectedIndex = 0;
  final ImagePicker picker = ImagePicker();

  void dodajZdjecie(int index) async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        miejsca[index].photo = File(photo.path);
      });
    }
  }

  void dodajMiejsce(BuildContext context) async {
    final String? nowaNazwa = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DodajMiejscePage()),
    );

    if (nowaNazwa != null && nowaNazwa.isNotEmpty) {
      setState(() {
        miejsca.add(Place(name: nowaNazwa));
      });
    }
  }

  Widget listaMiejsc() {
    return ListView.builder(
      itemCount: miejsca.length,
      itemBuilder: (context, index) {
        final place = miejsca[index];
        return Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            leading: place.photo != null
                ? Image.file(place.photo!, width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.place),
            title: Text(place.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SzczegolyMiejscaPage(place: place),
                ),
              );
            },
            trailing: ElevatedButton(
              onPressed: () => dodajZdjecie(index),
              child: Text('Zrób zdjęcie'),
            ),
          ),
        );
      },
    );
  }

  Widget galeriaZdjec() {
    final zdjecia = miejsca.where((p) => p.photo != null).map((p) => p.photo!).toList();
    if (zdjecia.isEmpty) {
      return Center(child: Text('Brak zdjęć'));
    }
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemCount: zdjecia.length,
      itemBuilder: (context, index) => Image.file(zdjecia[index], fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> strony = [listaMiejsc(), galeriaZdjec()];
    return Scaffold(
      appBar: AppBar(title: Text('Ciekawe miejsca')),
      body: strony[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int index) => setState(() => selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Miejsca'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Galeria'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => dodajMiejsce(context),
        tooltip: 'Dodaj miejsce',
        child: Icon(Icons.add),
      ),
    );
  }
}

class DodajMiejscePage extends StatelessWidget {
 
  final TextEditingController controller = TextEditingController();
  DodajMiejscePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj nowe miejsce')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Nazwa miejsca',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => submit(context),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => submit(context),
              child: Text('Dodaj'),
            ),
          ],
        ),
      ),
    );
  }

  void submit(BuildContext context) {
    final tekst = controller.text.trim();
    Navigator.pop(context, tekst);
  }
}

class SzczegolyMiejscaPage extends StatelessWidget {
  final Place place;
  const SzczegolyMiejscaPage({super.key, required this.place});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: Center(
        child: place.photo != null
            ? Image.file(place.photo!, fit: BoxFit.contain)
            : Text('Brak zdjęcia'),
      ),
    );
  }
}