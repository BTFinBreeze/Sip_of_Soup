import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/background_widget.dart';
import '../theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('请喝汤 S.O.S.', style: AppTheme.navTitleStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 76,
        iconTheme: const IconThemeData(color: AppTheme.goldLight, size: 34),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('个人中心功能开发中')),
            );
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BackgroundWidget(
        showSOS: false,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              const Text(
                '欢迎光临\n请喝汤',
                style: TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.goldLight,
                  height: 1.18,
                  shadows: [
                    Shadow(
                      color: AppTheme.gold,
                      blurRadius: 18,
                    ),
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please take a Sip of Soup',
                style: AppTheme.subtitleStyle,
              ),
              const SizedBox(height: 16),
              const _Ornament(),
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: () {
                  context.push('/stories');
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text('开始游戏'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('每日一汤功能开发中')),
                  );
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text('每日一汤'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('历史记录功能开发中')),
                  );
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text('历史记录'),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ornament extends StatelessWidget {
  const _Ornament();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Row(
        children: [
          Expanded(
              child:
                  Container(height: 1, color: AppTheme.gold.withOpacity(0.42))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('◇',
                style: TextStyle(color: AppTheme.goldLight, fontSize: 16)),
          ),
          Expanded(
              child:
                  Container(height: 1, color: AppTheme.gold.withOpacity(0.42))),
        ],
      ),
    );
  }
}
