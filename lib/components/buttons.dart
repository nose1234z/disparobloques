import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopButton extends PositionComponent with TapCallbacks {
  ShopButton({required Vector2 position, required VoidCallback onTap})
    : super(
        position: position,
        anchor: Anchor.topLeft,
        size: Vector2(70, 70), // Adjusted size for an icon
      ) {
    _onTap = onTap;
  }

  late final VoidCallback _onTap;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color.fromARGB(255, 222, 16, 16);
    canvas.drawRect(size.toRect(), paint);

    // Render shopping cart icon using TextPainter
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.shopping_cart.codePoint),
        style: TextStyle(
          fontFamily: Icons.shopping_cart.fontFamily,
          color: const Color.fromARGB(255, 0, 0, 0),
          fontSize: 60, // Adjust icon size
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _onTap();
  }
}

class LeaderboardButton extends PositionComponent with TapCallbacks {
  LeaderboardButton({required Vector2 position, required VoidCallback onTap})
    : super(
        position: position,
        anchor: Anchor.center,
        size: Vector2(140, 50), // Increased size
      ) {
    _onTap = onTap;
  }

  late final VoidCallback _onTap;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.green;
    canvas.drawRect(size.toRect(), paint);
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Leaderboard',
        style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _onTap();
  }
}
