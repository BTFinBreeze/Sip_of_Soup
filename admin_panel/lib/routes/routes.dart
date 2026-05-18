import 'package:go_router/go_router.dart';
import 'package:admin_panel/screens/login_screen.dart';
import 'package:admin_panel/screens/admin_screen.dart';

class AppRoutes {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );
}
