import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/story.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Story>? _allStories;
  List<Story>? _filteredStories;
  bool _isLoading = true;
  Story? _editingStory;
  bool _showAddForm = false;
  bool _hasSearched = false;

  final TextEditingController _searchController = TextEditingController();
  String? _selectedDifficulty;
  String? _selectedSoupType;

  final List<String> _difficulties = ['全部', '入门', '简单', '中等', '困难'];
  final List<String> _soupTypes = ['全部', '清汤', '红汤'];

  // 表单控制器
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _surfaceController = TextEditingController();
  final TextEditingController _truthController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  String _formDifficulty = '简单';

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _surfaceController.dispose();
    _truthController.dispose();
    _tagsController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  Future<void> _loadStories() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    try {
      await adminProvider.fetchStories();
      setState(() {
        _isLoading = false;
      });
      // 应用筛选
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载故事失败: $e')),
      );
    }
  }

  void _applyFilters() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    if (adminProvider.stories == null) return;

    List<Story> filtered = List.from(adminProvider.stories!);

    // 按标题搜索
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (_hasSearched && searchQuery.isNotEmpty) {
      filtered = filtered
          .where((story) => story.title.toLowerCase().contains(searchQuery))
          .toList();
    }

    // 按难度筛选
    if (_selectedDifficulty != null && _selectedDifficulty != '全部') {
      filtered = filtered
          .where((story) => story.difficulty == _selectedDifficulty)
          .toList();
    }

    // 按汤类型筛选
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

  void _showAddStoryForm() {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) => StoryFormDialog(
        story: null,
        titleController: _titleController,
        surfaceController: _surfaceController,
        truthController: _truthController,
        tagsController: _tagsController,
        keywordsController: _keywordsController,
        difficulty: _formDifficulty,
        onDifficultyChanged: _handleDifficultyChanged,
        onSave: _saveStoryAndClose,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showEditStoryForm(Story story) {
    _editingStory = story;
    _titleController.text = story.title;
    _surfaceController.text = story.surface;
    _truthController.text = story.truth;
    _tagsController.text = story.tags.join(',');
    _keywordsController.text = story.keywords.join(',');
    _formDifficulty = story.difficulty;

    showDialog(
      context: context,
      builder: (context) => StoryFormDialog(
        story: story,
        titleController: _titleController,
        surfaceController: _surfaceController,
        truthController: _truthController,
        tagsController: _tagsController,
        keywordsController: _keywordsController,
        difficulty: _formDifficulty,
        onDifficultyChanged: _handleDifficultyChanged,
        onSave: _saveStoryAndClose,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _handleDifficultyChanged(String? value) {
    if (value != null) {
      setState(() {
        _formDifficulty = value;
      });
    }
  }

  Future<void> _saveStoryAndClose() async {
    Navigator.of(context).pop();
    await _saveStory();
  }

  void _clearForm() {
    _titleController.clear();
    _surfaceController.clear();
    _truthController.clear();
    _tagsController.clear();
    _keywordsController.clear();
    _formDifficulty = '简单';
  }

  Future<void> _saveStory() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final keywords = _keywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final story = Story(
      id: _editingStory?.id,
      title: _titleController.text.trim(),
      surface: _surfaceController.text.trim(),
      truth: _truthController.text.trim(),
      tags: tags,
      difficulty: _formDifficulty,
      keywords: keywords,
    );

    bool success;
    if (_editingStory != null) {
      success = await adminProvider.updateStory(story);
    } else {
      success = await adminProvider.createStory(story);
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingStory != null ? '修改成功' : '添加成功')),
      );
      // 刷新故事列表
      await adminProvider.fetchStories();
      // 重新应用筛选
      _applyFilters();
      setState(() {
        _showAddForm = false;
        _editingStory = null;
      });
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingStory != null ? '修改失败' : '添加失败')),
      );
    }
  }

  void _deleteStory(int id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除故事"$title"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);
              final success = await adminProvider.deleteStory(id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
                // 刷新故事列表
                await adminProvider.fetchStories();
                // 重新应用筛选
                _applyFilters();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除失败')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认登出'),
        content: const Text('确定要登出吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);
              adminProvider.logout();
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('故事管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddStoryForm,
            tooltip: '添加故事',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: '登出',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_filteredStories == null ||
        (_filteredStories!.isEmpty && _hasSearched)) {
      return const Center(
        child: Text('搜索结果为空，请重新输入'),
      );
    }

    if (_filteredStories == null || _filteredStories!.isEmpty) {
      return const Center(
        child: Text('暂无故事'),
      );
    }

    return Column(
      children: [
        // 搜索框
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '搜索故事标题...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _onSearch,
                child: const Text('搜索'),
              ),
            ],
          ),
        ),

        // 筛选栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  hint: const Text('选择难度'),
                  items: _difficulties
                      .map((diff) => DropdownMenuItem(
                            value: diff,
                            child: Text(diff),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                    _applyFilters();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSoupType,
                  hint: const Text('选择汤类型'),
                  items: _soupTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSoupType = value;
                    });
                    _applyFilters();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 故事列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredStories!.length,
            itemBuilder: (context, index) {
              final story = _filteredStories![index];
              return Card(
                elevation: 2,
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
                                      label: Text(tag,
                                          style: const TextStyle(fontSize: 12)),
                                      backgroundColor: tag == '红汤'
                                          ? Colors.red.withOpacity(0.2)
                                          : tag == '清汤'
                                              ? Colors.blue.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.2),
                                      side: BorderSide(
                                        color: tag == '红汤'
                                            ? Colors.red
                                            : tag == '清汤'
                                                ? Colors.blue
                                                : Colors.grey,
                                      ),
                                    )),
                                Chip(
                                  label: Text(story.difficulty,
                                      style: const TextStyle(fontSize: 12)),
                                  backgroundColor:
                                      _getDifficultyColor(story.difficulty)
                                          .withOpacity(0.2),
                                  side: BorderSide(
                                      color: _getDifficultyColor(
                                          story.difficulty)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditStoryForm(story),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteStory(story.id!, story.title),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 添加/编辑故事对话框
class StoryFormDialog extends StatelessWidget {
  final Story? story;
  final TextEditingController titleController;
  final TextEditingController surfaceController;
  final TextEditingController truthController;
  final TextEditingController tagsController;
  final TextEditingController keywordsController;
  final String difficulty;
  final ValueChanged<String?> onDifficultyChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const StoryFormDialog({
    super.key,
    this.story,
    required this.titleController,
    required this.surfaceController,
    required this.truthController,
    required this.tagsController,
    required this.keywordsController,
    required this.difficulty,
    required this.onDifficultyChanged,
    required this.onSave,
    required this.onCancel,
  });

  static const List<String> _difficulties = ['入门', '简单', '中等', '困难'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                story != null ? '编辑故事' : '添加故事',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '标题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: surfaceController,
                decoration: const InputDecoration(
                  labelText: '汤面',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: truthController,
                decoration: const InputDecoration(
                  labelText: '汤底',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: '标签（用逗号分隔）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: keywordsController,
                decoration: const InputDecoration(
                  labelText: '汤底关键词（用逗号分隔）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: difficulty,
                decoration: const InputDecoration(
                  labelText: '难度',
                  border: OutlineInputBorder(),
                ),
                items: _difficulties
                    .map((diff) => DropdownMenuItem(
                          value: diff,
                          child: Text(diff),
                        ))
                    .toList(),
                onChanged: onDifficultyChanged,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSave,
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
