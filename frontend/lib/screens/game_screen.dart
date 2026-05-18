import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turtle_soup/providers/game_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/background_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendQuestion() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final question = _textController.text.trim();

    if (question.isEmpty || gameProvider.gameOver || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // 立即显示问题和加载状态
    gameProvider.startQuestion(question);
    _textController.clear();

    try {
      // Call backend API for AI response
      final answer = await gameProvider.askQuestion(question);

      // Update answer (replaces the loading indicator)
      gameProvider.finishQuestion(answer);

      // Check if game is won
      if (answer == '正确' || gameProvider.gameOver) {
        Future.delayed(const Duration(seconds: 1), () {
          context.push('/gameover');
        });
      }
    } catch (e) {
      print('Error sending question: $e');
      // 如果出错，更新答案显示错误信息
      gameProvider.finishQuestion('无法获取回答');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _giveUp() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.setGameLost();
    context.push('/gameover');
  }

  Future<void> _showHint() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    if (gameProvider.hintCount >= gameProvider.maxHints) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提示次数已用完'),
          content: const Text('每局游戏最多可查看3次提示'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call backend API for hint
      final hint = await gameProvider.getHint();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提示 (${gameProvider.hintCount}/${gameProvider.maxHints})'),
          content: Text(hint),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error getting hint: $e');
    } finally {
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
          title: const Text('游戏'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: BackgroundWidget(
          child: const Center(child: Text('请先选择故事', style: TextStyle(color: Colors.white))),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(story.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: BackgroundWidget(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Surface Story
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                story.surface,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

            // Question Counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '剩余提问次数: ${gameProvider.maxQuestions - gameProvider.questionCount}',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    '难度: ${story.difficulty}',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Chat Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: gameProvider.questions.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              gameProvider.questions[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(gameProvider.answers[index], style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Input Area
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: '输入你的问题...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        fillColor: Colors.white.withOpacity(0.1),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendQuestion(),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendQuestion,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Action Buttons
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _giveUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('放弃'),
                ),
                ElevatedButton(
                  onPressed: _showHint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('查看提示 (${gameProvider.hintCount}/${gameProvider.maxHints})'),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
