import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'body_component_with_user_data.dart';

const playerSize = 5.0;
const maxDragLength = 50.0; // Maximum pull distance for 100% force
const maxImpulseForce = 5000.0; // Maximum force to apply when fully pulled

enum PlayerColor {
  pink,
  blue,
  green,
  yellow;

  static PlayerColor get randomColor =>
      PlayerColor.values[Random().nextInt(PlayerColor.values.length)];

  String get fileName =>
      'alien${toString().split('.').last.capitalize}_round.png';
}

class Player extends BodyComponentWithUserData with DragCallbacks {
  Player(
    Vector2 position,
    Sprite sprite, {
    required this.onShoot,
    required this.canShoot,
  }) : _sprite = sprite,
       super(
         renderBody: false,
         bodyDef: BodyDef()
           ..position = position
           ..type = BodyType.static
           ..angularDamping = 0.1
           ..linearDamping = 0.1,
         fixtureDefs: [
           FixtureDef(CircleShape()..radius = playerSize / 2)
             ..restitution = 0.4
             ..density = 0.75
             ..friction = 0.5,
         ],
       );

  final Sprite _sprite;
  final VoidCallback onShoot;
  final bool Function() canShoot; // Callback to check if a shot is allowed
  final AudioPlayer _audioPlayer = AudioPlayer()
    ..setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {},
        ),
        android: AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );

  double jumpMultiplier = 1.0;
  bool isInvincible = false;

  @override
  Future<void> onLoad() {
    addAll([
      CustomPainterComponent(
        painter: _DragPainter(this),
        anchor: Anchor.center,
        size: Vector2(playerSize, playerSize),
        position: Vector2(0, 0),
      ),
      SpriteComponent(
        anchor: Anchor.center,
        sprite: _sprite,
        size: Vector2(playerSize, playerSize),
        position: Vector2(0, 0),
      ),
    ]);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!body.isAwake) {
      removeFromParent();
    }

    if (position.x > camera.visibleWorldRect.right + 10 ||
        position.x < camera.visibleWorldRect.left - 10) {
      removeFromParent();
    }
  }

  Vector2 _dragStart = Vector2.zero();
  Vector2 _dragDelta = Vector2.zero();
  Vector2 get dragDelta => _dragDelta;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (body.bodyType == BodyType.static) {
      _dragStart = event.localPosition;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (body.bodyType == BodyType.static) {
      _dragDelta = event.localEndPosition - _dragStart;
      if (_dragDelta.length > maxDragLength) {
        _dragDelta.setFrom(_dragDelta.normalized() * maxDragLength);
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (body.bodyType == BodyType.static && canShoot()) {
      // Check canShoot() here
      onShoot();
      final currentDragLength = _dragDelta.length;
      final forcePercentage = (currentDragLength / maxDragLength).clamp(
        0.0,
        1.0,
      );
      final appliedForceMagnitude = maxImpulseForce * forcePercentage;
      const strongShotThreshold = maxImpulseForce * 0.5; // 50% of max force

      if (appliedForceMagnitude > strongShotThreshold) {
        _audioPlayer.play(AssetSource('music/tiro.mp3'));
      } else {
        _audioPlayer.play(AssetSource('music/tirolento.mp3'));
      }
      children
          .whereType<CustomPainterComponent>()
          .firstOrNull
          ?.removeFromParent();
      body.setType(BodyType.dynamic);
      body.applyLinearImpulse(
        _dragDelta.normalized() * -appliedForceMagnitude * jumpMultiplier,
      ); // Apply impulse with jumpMultiplier
      add(RemoveEffect(delay: 5.0));
    }
  }

  // Methods to set/reset properties
  void setJumpMultiplier(double value) {
    jumpMultiplier = value;
  }

  void setInvincible(bool value) {
    isInvincible = value;
  }
}

extension on String {
  String get capitalize =>
      characters.first.toUpperCase() + characters.skip(1).toLowerCase().join();
}

class _DragPainter extends CustomPainter {
  _DragPainter(this.player);

  final Player player;

  @override
  void paint(Canvas canvas, Size size) {
    if (player.dragDelta != Vector2.zero()) {
      var center = size.center(Offset.zero);

      // Draw the drag line (optional, can be removed if only bar is desired)
      canvas.drawLine(
        center,
        center + (player.dragDelta * -1).toOffset(),
        Paint()
          ..color = Colors.orange.withAlpha(180)
          ..strokeWidth = 0.4
          ..strokeCap = StrokeCap.round,
      );

      // Calculate force percentage
      final currentDragLength = player.dragDelta.length;
      final forcePercentage = (currentDragLength / maxDragLength).clamp(
        0.0,
        1.0,
      );

      // Bar dimensions
      const barWidth = 20.0;
      const barHeight = 3.0;
      const barOffset = 10.0; // Offset above the player

      // Position the bar above the player
      final barRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - barOffset),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(1.5),
      );

      // Draw background of the bar
      canvas.drawRRect(
        barRect,
        Paint()..color = Colors.grey.withAlpha((255 * 0.5).round()),
      );

      // Draw filled part of the bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            barRect.left,
            barRect.top,
            barWidth * forcePercentage,
            barHeight,
          ),
          const Radius.circular(1.5),
        ),
        Paint()..color = Colors.red,
      );

      // Draw percentage text
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(forcePercentage * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 4.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          barRect.center.dx - textPainter.width / 2,
          barRect.top - textPainter.height - 1, // Above the bar
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
