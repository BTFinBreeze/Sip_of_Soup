import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/story.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _token = '';
  List<Story>? _stories;

  bool get isLoggedIn => _isLoggedIn;
  String get token => _token;
  List<Story>? get stories => _stories;

  Future<bool> login(String username, String password) async {
    try {
      print('Sending login request...');
      print('Username: $username');
      print('Password: $password');

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _token = '';
    _stories = null;
    notifyListeners();
  }

  Future<List<Story>> fetchStories() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/admin/stories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _stories = data.map((item) => Story.fromJson(item)).toList();
        _stories!.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        notifyListeners();
        return _stories!;
      } else {
        throw Exception('获取故事失败');
      }
    } catch (e) {
      print('Fetch stories error: $e');
      throw e;
    }
  }

  Future<bool> createStory(Story story) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/admin/stories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(story.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchStories();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Create story error: $e');
      return false;
    }
  }

  Future<bool> updateStory(Story story) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/admin/stories/${story.id!}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(story.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchStories();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Update story error: $e');
      return false;
    }
  }

  Future<bool> deleteStory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/admin/stories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        await fetchStories();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Delete story error: $e');
      return false;
    }
  }
}
