import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.0.19:5000';

  static Future<Map<String, dynamic>?> fetchUser(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$username'));
    print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Erreur API: ${response.body}');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllUsers() async {
  final response = await http.get(Uri.parse('$baseUrl/user/users'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map<Map<String, dynamic>>((item) => item as Map<String, dynamic>).toList();
  } else {
    print('Erreur récupération utilisateurs: ${response.body}');
    return [];
  }
}

  static Future<bool> addUser(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username}),
    );

    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> fetchWall(String WallId) async {
    final response = await http.get(Uri.parse('$baseUrl/wall/$WallId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Erreur récupération mur: ${response.body}');
      return null;
    }
  }

  static Future<bool> addWall(String color, String location) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wall/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'color': color, 'location': location}),
    );
    return response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> fetchAllWalls() async {
    final response = await http.get(Uri.parse('$baseUrl/wall/walls'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Erreur récupération murs: ${response.body}');
      return [];
    }
  }

  static Future<bool> removeWall(String wallId) async {
    final response = await http.delete(Uri.parse('$baseUrl/wall/remove/$wallId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erreur suppression mur: ${response.body}');
      return false;
    }
  }

  static Future<int> fetchWallCount() async {
    final response = await http.get(Uri.parse('$baseUrl/walls/count'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['total_walls'] as int;
    } else {
      print('Erreur récupération nombre de murs: ${response.body}');
      return 0;
    }
  }

  // User check a wall. Need username, wallId and sucess [0, 1] method PUT
  static Future<bool> checkWall(String username, String wallId, int success) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/update/$username/$wallId/$success'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'wallId': wallId, 'success': success}),
    );

    return response.statusCode == 200;
  }
  
}
