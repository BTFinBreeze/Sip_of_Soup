import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turtle_soup/providers/game_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/background_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  String _truth = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTruthAndEndGame();
  }

  Future<void> _loadTruthAndEndGame() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final story = gameProvider.currentStory;

    if (story != null) {
      try {
        // Get truth from backend
        final response = await http.get(
          Uri.parse('http://localhost:5000/api/stories/${story.id!}'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _truth = data['truth'] ?? '暂无汤底信息';
          });
        }

        // End game and save record
        await gameProvider.endGame(
          gameProvider.gameWon ? '胜利' : '失败',
          0, // 暂时不计算时间
        );
      } catch (e) {
        print('Error loading truth: $e');
        setState(() {
          _truth = '获取汤底失败';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final story = gameProvider.currentStory;

    if (story == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('游戏结束', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: BackgroundWidget(
          child: const Center(child: Text('无游戏数据', style: TextStyle(color: Colors.white))),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('游戏结束', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: BackgroundWidget(
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏结束', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            gameProvider.resetGame();
            context.push('/stories');
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Result
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: gameProvider.gameWon ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    gameProvider.gameWon ? '恭喜你，推理成功！' : '很遗憾，推理失败',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: gameProvider.gameWon ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),

              // Stats
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          '提问次数',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          '${gameProvider.questions.length}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          '提示次数',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          '${gameProvider.hintCount}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Truth
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '汤底：',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _truth,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Q&A History
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '推理过程：',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: gameProvider.questions.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Q: ${gameProvider.questions[index]}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text('A: ${gameProvider.answers[index]}', style: const TextStyle(color: Colors.white)),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        gameProvider.resetGame();
                        context.push('/stories');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('返回故事列表'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
