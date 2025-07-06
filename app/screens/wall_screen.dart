import 'package:flutter/material.dart';
import '../services/api_services.dart';

class WallScreen extends StatefulWidget {
  const WallScreen({super.key});

  @override
  State<WallScreen> createState() => _WallScreenState();
}

class _WallScreenState extends State<WallScreen> {
  String _result = "";

  // void _getWall() async {
  //   final wall = await ApiService.fetchUser("alice");
  //   setState(() {
  //     _result = wall != null ? "Nom: ${wall['username']}, Score: ${wall['score']}" : "Utilisateur introuvable";
  //   });
  // }

  List<Map<String, dynamic>> _allWalls = [];

  void _getAllWalls() async {
    final walls = await ApiService.fetchAllWalls();
    setState(() {
      _allWalls = walls;
    });
  }
  

  final TextEditingController _locationController = TextEditingController();
  String _selectedColor = 'green';
  final List<String> _colors = ['green', 'yellow', 'orange', 'blue', 'red', 'black', 'pink', 'white'];

  void _addWall() async {
    final location = _locationController.text.trim();
    final color = _selectedColor;
    if (location.isEmpty) return;
    await ApiService.addWall(color, location);


    _locationController.clear();
  }

  void _removeWall(String wallId) async {
    await ApiService.removeWall(wallId);
    _getAllWalls(); // Refresh the list after removal
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Routes", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.lightBlueAccent,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result),
            const SizedBox(height: 20),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Localisation du mur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedColor,
              items: _colors.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedColor = newValue!;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addWall,
              child: const Text("Ajouter mur"),
            ),
            ElevatedButton(
              onPressed: _getAllWalls,
              child: const Text("Chercher tous les murs"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _allWalls.length,
                itemBuilder: (context, index) {
                  final wall = _allWalls[index];
                  return ListTile(
                    title: Text(wall['id'].toString() + " | " + wall['location']),
                    subtitle: Text((wall['color'] ?? '-')+" | Score: "+(wall['score']?.toString() ?? '-')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
