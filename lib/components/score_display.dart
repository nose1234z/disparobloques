import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreDisplay extends PositionComponent {
  ScoreDisplay({required Vector2 position})
    : super(position: position, anchor: Anchor.topLeft);

  late final TextComponent _textComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _textComponent = TextComponent(
      text: 'Shots: 5',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          fontSize: 24,
          color: const Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_textComponent);
  }

  void updateScore(int score) {
    _textComponent.text = 'Shots: $score';
  }
}
