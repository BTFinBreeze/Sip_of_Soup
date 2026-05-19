import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/background_widget.dart';
import '../theme/theme.dart';

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

    gameProvider.startQuestion(question);
    _textController.clear();

    try {
      final answer = await gameProvider.askQuestion(question);

      gameProvider.finishQuestion(answer);

      if (answer == '正确' || gameProvider.gameOver) {
        Future.delayed(const Duration(seconds: 1), () {
          context.push('/gameover');
        });
      }
    } catch (e) {
      print('Error sending question: $e');
      gameProvider.finishQuestion('无法获取回答');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

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
          title: const Text('提示次数已用完', style: TextStyle(color: AppTheme.cream)),
          content: const Text('每局游戏最多可查看3次提示',
              style: TextStyle(color: AppTheme.cream)),
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppTheme.gold),
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
      final hint = await gameProvider.getHint();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提示 (${gameProvider.hintCount}/${gameProvider.maxHints})',
              style: TextStyle(color: AppTheme.cream)),
          content: Text(hint, style: TextStyle(color: AppTheme.cream)),
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppTheme.gold),
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
          title: const Text('游戏', style: AppTheme.navTitleStyle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: BackgroundWidget(
          child: const Center(
              child: Text('请先选择故事', style: TextStyle(color: AppTheme.cream))),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(story.title, style: AppTheme.navTitleStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 78,
        iconTheme: const IconThemeData(color: AppTheme.goldLight, size: 34),
      ),
      extendBodyBehindAppBar: true,
      body: BackgroundWidget(
        child: Column(
          children: [
            const SizedBox(height: 96),
            const _TitleRule(),
            const SizedBox(height: 22),
            Container(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.symmetric(horizontal: 22),
              decoration: AppTheme.cardDecoration,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                    child: Text(
                      story.surface,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cream,
                        height: 1.85,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                      height: 1, color: AppTheme.cardBorder.withOpacity(0.6)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '剩余提问次数: ${gameProvider.maxQuestions - gameProvider.questionCount}',
                          style: const TextStyle(
                              fontSize: 17, color: AppTheme.creamDark),
                        ),
                        Text(
                          '难度: ${story.difficulty}',
                          style: TextStyle(
                            fontSize: 17,
                            color:
                                AppTheme.getDifficultyColor(story.difficulty),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
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
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1e3a5f),
                                  Color(0xFF0d1b2a),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(22),
                                topRight: Radius.circular(22),
                                bottomLeft: Radius.circular(22),
                                bottomRight: Radius.circular(6),
                              ),
                              border: Border.all(
                                  color: AppTheme.blueChip, width: 1),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x660066CC),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text(
                              gameProvider.questions[index],
                              style: const TextStyle(
                                  color: AppTheme.cream, fontSize: 15),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(22),
                                topRight: Radius.circular(22),
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(22),
                              ),
                              border: Border.all(color: AppTheme.cardBorder),
                              boxShadow: const [AppTheme.cardShadow],
                            ),
                            child: Text(
                              gameProvider.answers[index],
                              style: const TextStyle(
                                  color: AppTheme.cream, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: AppTheme.textFieldDecoration('输入你的问题...'),
                      style: AppTheme.bodyStyle,
                      onSubmitted: (_) => _sendQuestion(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.goldLight, AppTheme.gold],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusButton),
                      boxShadow: [
                        AppTheme.glowShadow,
                      ],
                    ),
                    child: IconButton(
                      onPressed: _sendQuestion,
                      icon: const Icon(Icons.send_rounded,
                          color: AppTheme.ink, size: 32),
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _giveUp,
                      style: AppTheme.dangerButtonStyle,
                      child: const Text('放弃'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showHint,
                      style: AppTheme.hintButtonStyle,
                      child: Text(
                          '查看提示 (${gameProvider.hintCount}/${gameProvider.maxHints})'),
                    ),
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

class _TitleRule extends StatelessWidget {
  const _TitleRule();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      child: Row(
        children: [
          Expanded(
              child:
                  Container(height: 1, color: AppTheme.gold.withOpacity(0.52))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('◇◇',
                style: TextStyle(color: AppTheme.goldLight, fontSize: 14)),
          ),
          Expanded(
              child:
                  Container(height: 1, color: AppTheme.gold.withOpacity(0.52))),
        ],
      ),
    );
  }
}
