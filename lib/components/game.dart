import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers

import 'package:go_router/go_router.dart';

import 'brick.dart';

import 'buttons.dart';

import 'enemy.dart';

import 'ground.dart';

import 'player.dart';

import 'score_display.dart';

import 'background.dart';

import 'package:forge2d_game/models/power_up.dart'; // Import PowerUp model

class MyPhysicsGame extends Forge2DGame {
  MyPhysicsGame({
    required this.router,
    required this.onPowerUpPurchased,
    required this.onGameCreated, // Add onGameCreated callback
  }) : super(
         gravity: Vector2(0, 10),
         camera: CameraComponent.withFixedResolution(width: 800, height: 600),
       );

  final GoRouter router;
  final Function(PowerUp) onPowerUpPurchased;
  final Function(MyPhysicsGame)
  onGameCreated; // Callback to pass game instance back

  late final XmlSpriteSheet aliens;
  late final XmlSpriteSheet elements;
  late final XmlSpriteSheet tiles;

  int shotsLeft = 5;
  late final ScoreDisplay scoreDisplay;
  bool wonGame = false;
  late Player _player; // Declare player field
  final AudioPlayer _gameMusicPlayer =
      AudioPlayer(); // Audio player for game music

  @override
  FutureOr<void> onLoad() async {
    final backgroundImage = await images.load('colored_grass.png');
    final spriteSheets = await Future.wait([
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_aliens.png',
        xmlPath: 'spritesheet_aliens.xml',
      ),
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_elements.png',
        xmlPath: 'spritesheet_elements.xml',
      ),
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_tiles.png',
        xmlPath: 'spritesheet_tiles.xml',
      ),
    ]);

    aliens = spriteSheets[0];
    elements = spriteSheets[1];
    tiles = spriteSheets[2];

    await world.add(Background(sprite: Sprite(backgroundImage)));
    await addGround();
    unawaited(addBricks().then((_) => addEnemies()));
    await addPlayer();

    scoreDisplay = ScoreDisplay(position: Vector2(10, 10));
    camera.viewport.add(scoreDisplay);

    final shopButton = ShopButton(
      position: Vector2(
        20,
        camera.viewport.size.y - -170 - 50,
      ), // 50 is ShopButton's height
      onTap: () async {
        final purchasedPowerUp = await router.push<PowerUp>('/shop');
        if (purchasedPowerUp != null) {
          onPowerUpPurchased(purchasedPowerUp);
        }
      },
    );
    camera.viewport.add(shopButton);

    // Communicate game instance back to the Flutter widget tree
    onGameCreated(this);

    // Play game music
    _gameMusicPlayer.setReleaseMode(ReleaseMode.loop);
    // Configure AudioContext for background music
    _gameMusicPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {},
        ),
        android: AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
    _gameMusicPlayer.play(
      AssetSource('music/fondo.mp3'),
    ); // Assuming fondo.mp3 exists

    return super.onLoad();
  }

  @override
  void onRemove() {
    _gameMusicPlayer.stop();
    _gameMusicPlayer.dispose();
    super.onRemove();
  }

  // New method to apply power-up effects dynamically
  void applyPowerUp(PowerUp powerUp) {
    switch (powerUp.name) {
      case 'Super Jump':
        _player.setJumpMultiplier(2.0);
        add(
          TimerComponent(
            period: 10.0, // Duration of Super Jump
            onTick: () {
              _player.setJumpMultiplier(1.0); // Reset
            },
            removeOnFinish: true,
          ),
        );
        break;
      case 'Invincibility Shield':
        _player.setInvincible(true);
        add(
          TimerComponent(
            period: 5.0, // Duration of Invincibility
            onTick: () {
              _player.setInvincible(false); // Reset
            },
            removeOnFinish: true,
          ),
        );
        break;
      case 'Extra Shots':
        shotsLeft += 5;
        scoreDisplay.updateScore(shotsLeft); // Update display
        break;
      case 'Extra Life':
        shotsLeft += 1;
        scoreDisplay.updateScore(shotsLeft); // Update display
        break;
      default:
        // Handle unknown power-ups or do nothing
        break;
    }
  }

  Future<void> addGround() {
    return world.addAll([
      for (
        var x = camera.visibleWorldRect.left;
        x < camera.visibleWorldRect.right + groundSize;
        x += groundSize
      )
        Ground(
          Vector2(x, (camera.visibleWorldRect.height - groundSize) / 2),
          tiles.getSprite('grass.png'),
        ),
    ]);
  }

  final _random = Random();

  Future<void> addBricks() async {
    for (var i = 0; i < 5; i++) {
      final type = BrickType.randomType;
      final size = BrickSize.randomSize;
      await world.add(
        Brick(
          type: type,
          size: size,
          damage: BrickDamage.some,
          position: Vector2(
            camera.visibleWorldRect.right / 3 +
                (_random.nextDouble() * 5 - 2.5),
            0,
          ),
          sprites: brickFileNames(
            type,
            size,
          ).map((key, filename) => MapEntry(key, elements.getSprite(filename))),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> addPlayer() async {
    _player = Player(
      // Assign to _player
      Vector2(camera.visibleWorldRect.left * 2 / 3, 0),
      aliens.getSprite(PlayerColor.randomColor.fileName),
      onShoot: () {
        shotsLeft--;
        scoreDisplay.updateScore(shotsLeft);
      },
      canShoot: () => shotsLeft > 0, // Pass the canShoot check
    );
    world.add(_player); // Add the player to the world
  }

  @override
  void update(double dt) {
    super.update(dt);
    final allEnemiesRemoved = world.children.whereType<Enemy>().isEmpty;
    final noPlayersLeft = world.children.whereType<Player>().isEmpty;

    if (isMounted && noPlayersLeft && !allEnemiesRemoved && shotsLeft == 0) {
      // Game over (lost)
      router.go('/game-over', extra: {'score': shotsLeft, 'won': wonGame});
    } else if (isMounted && enemiesFullyAdded && allEnemiesRemoved) {
      // Game over (won)
      wonGame = true;
      router.go('/game-over', extra: {'score': shotsLeft, 'won': wonGame});
    } else if (isMounted && noPlayersLeft && !allEnemiesRemoved) {
      addPlayer();
    }
  }

  var enemiesFullyAdded = false;

  Future<void> addEnemies() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    for (var i = 0; i < 3; i++) {
      await world.add(
        Enemy(
          Vector2(
            camera.visibleWorldRect.right / 3 +
                (_random.nextDouble() * 7 - 3.5),
            (_random.nextDouble() * 3),
          ),
          aliens.getSprite(EnemyColor.randomColor.fileName),
        ),
      );
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    enemiesFullyAdded = true;
  }
}
