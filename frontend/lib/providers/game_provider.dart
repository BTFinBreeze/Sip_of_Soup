import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/story.dart';

class GameProvider extends ChangeNotifier {
  Story? _currentStory;
  int _questionCount = 0;
  final int _maxQuestions = 15;
  bool _gameOver = false;
  bool _gameWon = false;
  List<String> _questions = [];
  List<String> _answers = [];
  int _hintCount = 0;
  final int _maxHints = 3;

  Story? get currentStory => _currentStory;
  int get questionCount => _questionCount;
  int get maxQuestions => _maxQuestions;
  bool get gameOver => _gameOver;
  bool get gameWon => _gameWon;
  List<String> get questions => _questions;
  List<String> get answers => _answers;
  int get hintCount => _hintCount;
  int get maxHints => _maxHints;

  void setCurrentStory(Story story) {
    _currentStory = story;
    _questionCount = 0;
    _gameOver = false;
    _gameWon = false;
    _questions = [];
    _answers = [];
    _hintCount = 0;
    notifyListeners();
  }

  void addQuestion(String question, String answer) {
    if (_gameOver) return;

    _questions.add(question);
    _answers.add(answer);
    _questionCount++;

    // Check if game is over
    if (_questionCount >= _maxQuestions) {
      _gameOver = true;
      _gameWon = false;
    }

    notifyListeners();
  }

  // 开始提问（立即显示问题和加载状态）
  void startQuestion(String question) {
    if (_gameOver) return;

    _questions.add(question);
    _answers.add('...');  // 加载状态占位符
    notifyListeners();
  }

  // 完成提问（更新答案）
  void finishQuestion(String answer) {
    if (_gameOver || _answers.isEmpty) return;

    // 更新最后一个答案
    _answers[_answers.length - 1] = answer;
    _questionCount++;

    // Check if game is over
    if (_questionCount >= _maxQuestions) {
      _gameOver = true;
      _gameWon = false;
    }

    if (answer == '正确') {
      setGameWon();
    }

    notifyListeners();
  }

  void setGameWon() {
    _gameOver = true;
    _gameWon = true;
    notifyListeners();
  }

  void setGameLost() {
    _gameOver = true;
    _gameWon = false;
    notifyListeners();
  }

  void resetGame() {
    _currentStory = null;
    _questionCount = 0;
    _gameOver = false;
    _gameWon = false;
    _questions = [];
    _answers = [];
    _hintCount = 0;
    notifyListeners();
  }

  Future<List<Story>> fetchAllStories() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/stories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final stories = data.map((item) {
          return Story(
            id: item['id'],
            title: item['title'],
            surface: item['surface'],
            truth: '',
            tags: List<String>.from(item['tags']),
            difficulty: item['difficulty'],
            keywords: List<String>.from(item['keywords']),
          );
        }).toList();
        // 根据 story id 排序
        stories.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        return stories;
      } else {
        print('Failed to fetch stories: ${response.statusCode}');
        throw Exception('获取故事失败');
      }
    } catch (e) {
      print('Error fetching stories: $e');
      throw e;
    }
  }

  Future<Story?> fetchStory(String soupType, String difficulty) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/game/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'soup_type': soupType,
          'difficulty': difficulty,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final story = Story(
          id: data['id'],
          title: data['title'],
          surface: data['surface'],
          truth: '', // 后端不会返回汤底，前端不需要知道
          tags: [],
          difficulty: data['difficulty'],
          keywords: [],
        );
        setCurrentStory(story);
        return story;
      } else {
        print('Failed to fetch story: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching story: $e');
      return null;
    }
  }

  Future<String> askQuestion(String question) async {
    if (_currentStory == null) return '故事不存在';

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/game/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'story_id': _currentStory!.id,
          'question': question,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'] ?? '未知回答';
        // 不再调用 addQuestion，由 game_screen 使用 startQuestion 和 finishQuestion
        return answer;
      } else {
        print('Failed to ask question: ${response.statusCode}');
        return '无法获取回答';
      }
    } catch (e) {
      print('Error asking question: $e');
      return '无法获取回答';
    }
  }

  Future<String> getHint() async {
    if (_currentStory == null || _hintCount >= _maxHints) return '提示已用完';

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/game/hint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'story_id': _currentStory!.id,
          'hint_index': _hintCount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hint = data['hint'] ?? '无提示';
        _hintCount++;
        notifyListeners();
        return hint;
      } else {
        print('Failed to get hint: ${response.statusCode}');
        return '无法获取提示';
      }
    } catch (e) {
      print('Error getting hint: $e');
      return '无法获取提示';
    }
  }

  Future<bool> endGame(String result, int timeUsed) async {
    if (_currentStory == null) return false;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/game/end'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'story_id': _currentStory!.id,
          'questions_used': _questionCount,
          'hints_used': _hintCount,
          'result': result,
          'time_used': timeUsed,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to end game: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error ending game: $e');
      return false;
    }
  }
}
