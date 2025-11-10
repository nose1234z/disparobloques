import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services.dart
import 'package:go_router/go_router.dart';
import 'package:forge2d_game/components/game.dart';
import 'package:forge2d_game/screens/game_over_screen.dart';
import 'package:forge2d_game/screens/leaderboard_screen.dart';
import 'package:forge2d_game/screens/play_again_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:forge2d_game/screens/shop_screen.dart'; // Import ShopScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Make the app full screen
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  await Supabase.initialize(
    url: 'https://qsccvdqpprgnxwzqvfvv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzY2N2ZHFwcHJnbnh3enF2ZnZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxNjE0ODAsImV4cCI6MjA3NzczNzQ4MH0.xQK12EHXYQYKhhXECBo-BUk2oU0IWJW1_lRPDJ2OuTc',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  MyPhysicsGame? _game; // Store the game instance

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => GameWidget.controlled(
            gameFactory: () => MyPhysicsGame(
              router: _router,
              onPowerUpPurchased: (powerUp) {
                _game?.applyPowerUp(
                  powerUp,
                ); // Apply power-up to the running game
              },
              onGameCreated: (game) {
                _game = game; // Store the game instance
              },
            ),
          ),
        ),
        GoRoute(
          path: '/game-over',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final score = extra['score'] as int;
            final won = extra['won'] as bool;
            return GameOverScreen(score: score, won: won);
          },
        ),
        GoRoute(
          path: '/play-again',
          builder: (context, state) => const PlayAgainScreen(),
        ),
        GoRoute(path: '/shop', builder: (context, state) => const ShopScreen()),
        GoRoute(
          path: '/leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
