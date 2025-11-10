import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers

class PlayAgainScreen extends StatefulWidget {
  const PlayAgainScreen({super.key});

  @override
  State<PlayAgainScreen> createState() => _PlayAgainScreenState();
}

class _PlayAgainScreenState extends State<PlayAgainScreen> {
  final AudioPlayer _playAgainMusicPlayer =
      AudioPlayer(); // Audio player for play again music

  @override
  void initState() {
    super.initState();
    _playAgainMusicPlayer.setReleaseMode(ReleaseMode.loop);
    _playAgainMusicPlayer.play(
      AssetSource('music/play_again.mp3'),
    ); // Assuming play_again.mp3 exists
  }

  @override
  void dispose() {
    _playAgainMusicPlayer.stop();
    _playAgainMusicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/colored_grass.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            color: Colors.white.withAlpha((255 * 0.8).round()),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Play Again',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    iconSize: 64,
                    onPressed: () {
                      // Pass the active power-up to the game
                      context.go('/');
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
