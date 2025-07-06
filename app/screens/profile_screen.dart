import 'package:flutter/material.dart';
import '../services/api_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _result = "";

  // void _getUser() async {
  //   final user = await ApiService.fetchUser("alice");
  //   setState(() {
  //     _result = user != null ? "Nom: ${user['username']}, Score: ${user['score']}" : "Utilisateur introuvable";
  //   });
  // }

  List<Map<String, dynamic>> _allUsers = [];

  void _getAllUsers() async {
    final users = await ApiService.fetchAllUsers();
    setState(() {
      _allUsers = users;
    });
  }
  

  final TextEditingController _usernameController = TextEditingController();

  void _addUser() async {
  final username = _usernameController.text.trim();
  if (username.isEmpty) return;
  await ApiService.addUser(username);


  _usernameController.clear();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profiles", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.redAccent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d’utilisateur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text("Ajouter utilisateur"),
            ),
            ElevatedButton(
              onPressed: _getAllUsers,
              child: const Text("Chercher tous les utilisateurs"),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView.builder(
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  final user = _allUsers[index];
                  return ListTile(
                    title: Text(user['username']),
                    subtitle: Text("Score: ${user['score']}"),
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
