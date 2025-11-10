import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import 'body_component_with_user_data.dart';
import 'brick.dart';
import 'player.dart';

const enemySize = 5.0;

enum EnemyColor {
  pink(color: 'pink', boss: false),
  blue(color: 'blue', boss: false),
  green(color: 'green', boss: false),
  yellow(color: 'yellow', boss: false),
  pinkBoss(color: 'pink', boss: true),
  blueBoss(color: 'blue', boss: true),
  greenBoss(color: 'green', boss: true),
  yellowBoss(color: 'yellow', boss: true);

  final bool boss;
  final String color;

  const EnemyColor({required this.color, required this.boss});

  static EnemyColor get randomColor =>
      EnemyColor.values[Random().nextInt(EnemyColor.values.length)];

  String get fileName =>
      'alien${color.capitalize}_${boss ? 'suit' : 'square'}.png';
}

class Enemy extends BodyComponentWithUserData with ContactCallbacks {
  Enemy(Vector2 position, Sprite sprite)
    : super(
        renderBody: false,
        bodyDef: BodyDef()
          ..position = position
          ..type = BodyType.dynamic,
        fixtureDefs: [
          FixtureDef(
            PolygonShape()..setAsBoxXY(enemySize / 2, enemySize / 2),
            friction: 0.3,
          ),
        ],
        children: [
          SpriteComponent(
            anchor: Anchor.center,
            sprite: sprite,
            size: Vector2.all(enemySize),
            position: Vector2(0, 0),
          ),
        ],
      );

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

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Player) {
      if (other.isInvincible) {
        // If player is invincible, ignore contact
        return;
      }
      final interceptVelocity =
          (contact.bodyA.linearVelocity - contact.bodyB.linearVelocity).length
              .abs();
      if (interceptVelocity > 5) {
        Vibration.hasVibrator().then((hasVibrator) {
          if (hasVibrator == true) {
            Vibration.vibrate();
          }
        });
        _audioPlayer.play(AssetSource('music/daño.mp3'));
        removeFromParent();
      }
    } else if (other is Brick) {
      final interceptVelocity =
          (contact.bodyA.linearVelocity - contact.bodyB.linearVelocity).length
              .abs();
      if (interceptVelocity > 5) {
        Vibration.hasVibrator().then((hasVibrator) {
          if (hasVibrator == true) {
            Vibration.vibrate();
          }
        });
        _audioPlayer.play(AssetSource('music/daño.mp3'));
        removeFromParent();
      }
    }

    super.beginContact(other, contact);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (position.x > camera.visibleWorldRect.right + 10 ||
        position.x < camera.visibleWorldRect.left - 10) {
      removeFromParent();
    }
  }
}

extension on String {
  String get capitalize =>
      characters.first.toUpperCase() + characters.skip(1).toLowerCase().join();
}
