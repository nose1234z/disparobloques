import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key, required this.score, required this.won});

  final int score;
  final bool won;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = nameController.text.trim();
    if (name.isNotEmpty) {
      try {
        await Supabase.instance.client.from('score').insert({
          'nombre_player': name,
          'disparos': widget.score,
          'fecha_juego': DateTime.now().toIso8601String(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Score submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on PostgrestException catch (e) {
        debugPrint('Supabase Error: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting score: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('An unexpected error occurred: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    if (mounted) {
      context.go('/play-again');
    }
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
          child: SingleChildScrollView(
            child: Card(
              color: const Color.fromARGB(
                255,
                255,
                255,
                255,
              ).withAlpha((255 * 0.8).round()),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.won ? 'You Win!' : 'Game Over!',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your score: ${widget.score}',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your name',
                        border: OutlineInputBorder(),
                      ),
                      style: GoogleFonts.pressStart2p(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ), // Darker background color
                      ),
                      onPressed: _handleSubmit,
                      child: Text(
                        'Submit',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 16,
                          color: Colors.white, // White text for contrast
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
