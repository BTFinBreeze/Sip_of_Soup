import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/story.dart';
import '../widgets/background_widget.dart';
import '../theme/theme.dart';

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

    final searchQuery = _searchController.text.toLowerCase().trim();
    if (_hasSearched && searchQuery.isNotEmpty) {
      filtered = filtered
          .where((story) => story.title.toLowerCase().contains(searchQuery))
          .toList();
    }

    if (_selectedDifficulty != null && _selectedDifficulty != '全部') {
      filtered = filtered
          .where((story) => story.difficulty == _selectedDifficulty)
          .toList();
    }

    if (_selectedSoupType != null && _selectedSoupType != '全部') {
      filtered = filtered
          .where((story) => story.tags.contains(_selectedSoupType))
          .toList();
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
          final gameProvider =
              Provider.of<GameProvider>(context, listen: false);
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
        title: const Text('选择故事', style: AppTheme.navTitleStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 78,
        iconTheme: const IconThemeData(color: AppTheme.goldLight, size: 34),
      ),
      extendBodyBehindAppBar: true,
      body: BackgroundWidget(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.gold))
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredStories == null ||
        (_filteredStories!.isEmpty && _hasSearched)) {
      return const Center(
        child: Text(
          '搜索结果为空，请重新输入',
          style: TextStyle(color: AppTheme.cream, fontSize: 18),
        ),
      );
    }

    if (_filteredStories == null || _filteredStories!.isEmpty) {
      return const Center(
        child: Text(
          '暂无故事',
          style: TextStyle(color: AppTheme.cream, fontSize: 18),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 96),
        const _TitleRule(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: AppTheme.textFieldDecoration(
                    '搜索故事标题...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.creamDark, size: 30),
                  ),
                  style: AppTheme.bodyStyle,
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _onSearch,
                style: AppTheme.searchButtonStyle,
                child: const Text('搜索'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  icon: Icons.bar_chart_rounded,
                  value: _selectedDifficulty,
                  hint: '选择难度',
                  items: _difficulties,
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterDropdown(
                  icon: Icons.local_offer_outlined,
                  value: _selectedSoupType,
                  hint: '选择汤类型',
                  items: _soupTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedSoupType = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: AppTheme.cardTitleStyle,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...story.tags.map((tag) => _StoryChip(
                            text: tag,
                            color: AppTheme.getTagColor(tag),
                          )),
                      _StoryChip(
                        text: story.difficulty,
                        color: AppTheme.getDifficultyColor(story.difficulty),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.goldLight,
              size: 28,
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
      width: 180,
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

class _FilterDropdown extends StatelessWidget {
  final IconData icon;
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.icon,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: AppTheme.filterDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: AppTheme.creamDark, size: 22),
              const SizedBox(width: 10),
              Flexible(child: Text(hint, style: AppTheme.bodyStyle)),
            ],
          ),
          selectedItemBuilder: (context) => items
              .map((item) => Row(
                    children: [
                      Icon(icon, color: AppTheme.creamDark, size: 22),
                      const SizedBox(width: 10),
                      Flexible(child: Text(item, style: AppTheme.bodyStyle)),
                    ],
                  ))
              .toList(),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: AppTheme.bodyStyle),
                ),
              )
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.goldLight),
          dropdownColor: AppTheme.brownDark,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
    );
  }
}

class _StoryChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StoryChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: AppTheme.chipDecoration(color),
      child: Text(text, style: AppTheme.chipTextStyle(color)),
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
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: AppTheme.cardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              story.title,
              style: AppTheme.cardTitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('难度: ', style: TextStyle(color: AppTheme.cream)),
                Text(
                  story.difficulty,
                  style: TextStyle(
                    color: AppTheme.getDifficultyColor(story.difficulty),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.cardBorder),
            const SizedBox(height: 16),
            const Text(
              '汤面:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.cream,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Text(
                story.surface,
                style: AppTheme.bodyStyle,
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
                      backgroundColor: const Color(0x994D4336),
                      foregroundColor: AppTheme.cream,
                      side: const BorderSide(color: AppTheme.greyChip),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusButton),
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
                    style: AppTheme.primaryButtonStyle,
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
