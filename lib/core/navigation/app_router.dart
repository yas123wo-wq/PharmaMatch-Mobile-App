// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/drug_detail_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/favorites_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../domain/entities/drug_entity.dart';

class AppRouter {
  static const String main      = '/';
  static const String home      = '/home';
  static const String search    = '/search';
  static const String favorites = '/favorites';
  static const String profile   = '/profile';
  static const String drugDetail = '/drug-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case drugDetail:
        final drug = settings.arguments as DrugEntity;
        return MaterialPageRoute(builder: (_) => DrugDetailScreen(drug: drug));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('الصفحة غير موجودة: ${settings.name}')),
          ),
        );
    }
  }
}
