import 'package:go_router/go_router.dart';
import 'package:turtle_soup/screens/home_screen.dart';
import 'package:turtle_soup/screens/story_list_screen.dart';
import 'package:turtle_soup/screens/game_screen.dart';
import 'package:turtle_soup/screens/game_over_screen.dart';

class AppRoutes {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/stories',
        builder: (context, state) => const StoryListScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: '/gameover',
        builder: (context, state) => const GameOverScreen(),
      ),
    ],
  );
}
