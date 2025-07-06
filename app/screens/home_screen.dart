import 'package:flutter/material.dart';
import '../services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _wallId = 0;
  int _wallCount = 0;

  final TextEditingController _usernameController = TextEditingController();

  void _checkWall(int wallId, int success) async {
    await ApiService.checkWall(
      _usernameController.text.trim(),
      wallId.toString(),
      success
    );
  }

  void _getWallCount() async {
    _wallCount = await ApiService.fetchWallCount();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getWallCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom du grimpeur',
                border: OutlineInputBorder(),
              ),
            ),
            DropdownButton<int>(
              iconSize: 50,
              value: _wallId,
              items: List.generate(
                _wallCount + 1,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(index.toString()),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _wallId = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(50.0)
                  ),
                  onPressed: () {
                    _checkWall(_wallId, 0);
                    
                  },
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(50.0)
                  ),
                  onPressed: () {
                    _checkWall(_wallId, 1);
                  },
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}