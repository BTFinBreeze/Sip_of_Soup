import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turtle_soup/providers/game_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/background_widget.dart';

class GenreSelectionScreen extends StatefulWidget {
  const GenreSelectionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GenreSelectionScreenState createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  int _currentStep = 0; // 0: 选择汤类型, 1: 选择难度
  String? _selectedSoupType; // 清汤或红汤
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentStep == 0 ? '选择汤类型' : '选择难度',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _currentStep == 0
              ? _buildSoupTypeSelection(context)
              : _buildDifficultySelection(context, gameProvider),
        ),
      ),
    );
  }

  Widget _buildSoupTypeSelection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '请选择汤类型',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSoupTypeCard(context, '清汤', Colors.blue),
              _buildSoupTypeCard(context, '红汤', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoupTypeCard(
      BuildContext context, String soupType, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSoupType = soupType;
          _currentStep = 1;
        });
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              soupType,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelection(
      BuildContext context, GameProvider gameProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '请选择游戏难度',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDifficultyCard(
                  context, gameProvider, '简单', Colors.lightGreen),
              _buildDifficultyCard(
                  context, gameProvider, '中等', Colors.blueGrey),
              _buildDifficultyCard(context, gameProvider, '困难', Colors.brown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(BuildContext context, GameProvider gameProvider,
      String difficulty, Color color) {
    return GestureDetector(
      onTap: () async {
        if (_isLoading || _selectedSoupType == null) return;

        setState(() {
          _isLoading = true;
        });

        try {
          // Call backend API to fetch story
          final story =
              await gameProvider.fetchStory(_selectedSoupType!, difficulty);

          if (story != null) {
            context.push('/game');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('该类型暂无故事')),
            );
          }
        } catch (e) {
          print('Error fetching story: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('获取故事失败，请重试')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              difficulty,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
