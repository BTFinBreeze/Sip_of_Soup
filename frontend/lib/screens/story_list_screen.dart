import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/story.dart';
import '../widgets/background_widget.dart';

class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  List<Story>? _allStories;
  List<Story>? _filteredStories;
  bool _isLoading = true;
  Story? _selectedStory;
  bool _hasSearched = false;
  
  final TextEditingController _searchController = TextEditingController();
  String? _selectedDifficulty;
  String? _selectedSoupType;
  
  final List<String> _difficulties = ['全部', '入门', '简单', '中等', '困难'];
  final List<String> _soupTypes = ['全部', '清汤', '红汤'];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStories() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    try {
      final stories = await gameProvider.fetchAllStories();
      setState(() {
        _allStories = stories;
        _filteredStories = stories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载故事失败: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    if (_allStories == null) return;

    List<Story> filtered = List.from(_allStories!);

    // 按标题搜索
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (_hasSearched && searchQuery.isNotEmpty) {
      filtered = filtered.where((story) => 
        story.title.toLowerCase().contains(searchQuery)
      ).toList();
    }

    // 按难度筛选
    if (_selectedDifficulty != null && _selectedDifficulty != '全部') {
      filtered = filtered.where((story) => 
        story.difficulty == _selectedDifficulty
      ).toList();
    }

    // 按汤类型筛选
    if (_selectedSoupType != null && _selectedSoupType != '全部') {
      filtered = filtered.where((story) => 
        story.tags.contains(_selectedSoupType)
      ).toList();
    }

    setState(() {
      _filteredStories = filtered;
    });
  }

  void _onSearch() {
    setState(() {
      _hasSearched = true;
    });
    _applyFilters();
  }

  void _showStoryDetail(Story story) {
    setState(() {
      _selectedStory = story;
    });
    showDialog(
      context: context,
      builder: (context) => StoryDetailDialog(
        story: story,
        onStartGame: () {
          final gameProvider = Provider.of<GameProvider>(context, listen: false);
          gameProvider.setCurrentStory(story);
          context.push('/game');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择故事', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: BackgroundWidget(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredStories == null || (_filteredStories!.isEmpty && _hasSearched)) {
      return const Center(
        child: Text(
          '搜索结果为空，请重新输入',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    if (_filteredStories == null || _filteredStories!.isEmpty) {
      return const Center(
        child: Text(
          '暂无故事',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 70),
        // 搜索框
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索故事标题...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _onSearch,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('搜索'),
              ),
            ],
          ),
        ),

        // 筛选栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // 难度筛选
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: _selectedDifficulty,
                    hint: const Text('选择难度', style: TextStyle(color: Colors.white)),
                    items: _difficulties.map((diff) => DropdownMenuItem(
                      value: diff,
                      child: Text(diff, style: const TextStyle(color: Colors.black)),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value;
                      });
                      _applyFilters();
                    },
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 汤类型筛选
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: _selectedSoupType,
                    hint: const Text('选择汤类型', style: TextStyle(color: Colors.white)),
                    items: _soupTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type, style: const TextStyle(color: Colors.black)),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSoupType = value;
                      });
                      _applyFilters();
                    },
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 故事列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredStories!.length,
            itemBuilder: (context, index) {
              final story = _filteredStories![index];
              return StoryCard(
                story: story,
                onTap: () => _showStoryDetail(story),
              );
            },
          ),
        ),
      ],
    );
  }
}

class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
  });

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '简单':
        return Colors.lightGreen;
      case '中等':
        return Colors.orange;
      case '困难':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getSoupTypeColor(List<String> tags) {
    if (tags.contains('红汤')) {
      return Colors.red;
    } else if (tags.contains('清汤')) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ...story.tags.map((tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _getSoupTypeColor(story.tags)
                                  .withOpacity(0.2),
                              side: BorderSide(
                                color: _getSoupTypeColor(story.tags),
                                width: 1,
                              ),
                              visualDensity: VisualDensity.compact,
                            )),
                        Chip(
                          label: Text(
                            story.difficulty,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor:
                              _getDifficultyColor(story.difficulty).withOpacity(0.2),
                          side: BorderSide(
                            color: _getDifficultyColor(story.difficulty),
                            width: 1,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoryDetailDialog extends StatelessWidget {
  final Story story;
  final VoidCallback onStartGame;

  const StoryDetailDialog({
    super.key,
    required this.story,
    required this.onStartGame,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              story.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('难度: '),
                Text(
                  story.difficulty,
                  style: TextStyle(
                    color: story.difficulty == '简单'
                        ? Colors.lightGreen
                        : story.difficulty == '中等'
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '汤面:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                story.surface,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onStartGame();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('开始喝汤'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
