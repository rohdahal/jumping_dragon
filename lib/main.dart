import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    GameWidget(game: JumpingGame()),
  );
}

// 🔹 Main Game Class
class JumpingGame extends FlameGame with KeyboardEvents {
  late Character character;
  late List<Turtle> turtles;
  late double groundLevel;
  int score = 0;
  bool isGameOver = false;
  bool gameStarted = false;

  @override
  Future<void> onLoad() async {
    groundLevel = size.y - 50;

    // ✅ Add background first
    add(Background());

    // ✅ Show start button before game starts
    add(StartScreen(onStart: startGame));
  }

  void startGame() {
    if (gameStarted) return;
    gameStarted = true;
    isGameOver = false;
    score = 0;

    // ✅ Remove Start Screen
    removeWhere((component) => component is StartScreen);

    // ✅ Add Character
    character = Character(Vector2(50, groundLevel));
    add(character);

    // ✅ Add Turtles (Obstacles)
    turtles = [
      Turtle(Vector2(size.x + 100, groundLevel)),
      Turtle(Vector2(size.x + 300, groundLevel - 100), isFlying: true),
    ];
    turtles.forEach(add);

    // ✅ Add Score Display
    add(ScoreDisplay());
  }

  void increaseScore(int points) {
    if (!isGameOver) {
      score += points;
      print("Score: $score");
    }
  }

  void gameOver() {
    if (!isGameOver) {
      isGameOver = true;
      print("Game Over! Final Score: $score");

      // ✅ Show Game Over Screen
      add(GameOverScreen(score: score));
    }
  }

  void resetGame() {
    removeAll(children); // Remove all components
    gameStarted = false;
    isGameOver = false;
    score = 0;
    onLoad(); // Restart game
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (isGameOver || !gameStarted) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        character.jump(normal: true);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        character.jump(normal: false);
      }
    }
    return KeyEventResult.handled;
  }
}

// 🔹 Character Class (Player)
class Character extends SpriteComponent with HasGameRef<JumpingGame> {
  static const double jumpVelocity = -450;
  static const double highJumpVelocity = -750;
  static const double gravity = 800;

  late Vector2 velocity;
  bool isJumping = false;

  Character(Vector2 position)
      : super(position: position, size: Vector2(50, 50), anchor: Anchor.bottomCenter) {
    velocity = Vector2.zero();
  }

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('character.png');
  }

  void jump({required bool normal}) {
    if (!isJumping) {
      velocity.y = normal ? jumpVelocity : highJumpVelocity;
      isJumping = true;
    }
  }

  @override
  void update(double dt) {
    if (gameRef.isGameOver) return;

    velocity.y += gravity * dt; // Apply gravity
    position += velocity * dt;

    if (position.y >= gameRef.groundLevel) {
      position.y = gameRef.groundLevel;
      isJumping = false;
      velocity.y = 0;
    }
  }
}

// 🔹 Turtle (Obstacle)
class Turtle extends SpriteComponent with HasGameRef<JumpingGame> {
  final bool isFlying;
  static const double speed = -150;
  bool scored = false;

  Turtle(Vector2 position, {this.isFlying = false})
      : super(position: position, size: Vector2(50, 50), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(isFlying ? 'flying_turtle.png' : 'turtle.png');
  }

  @override
  void update(double dt) {
    if (gameRef.isGameOver) return;

    position.x += speed * dt;
    if (position.x < -50) {
      position.x = gameRef.size.x + Random().nextInt(300) + 100; // Randomized respawn
      scored = false;
    }

    // ✅ Fix Collision Detection
    if (gameRef.character.toRect().overlaps(toRect())) {
      gameRef.gameOver();
    }

    // ✅ Increase Score when successfully jumped over
    if (!scored && gameRef.character.position.y < position.y - 30) {
      scored = true;
      gameRef.increaseScore(isFlying ? 3 : 1);
    }
  }
}

// 🔹 Background Component
class Background extends SpriteComponent with HasGameRef<JumpingGame> {
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('background.png');
    size = gameRef.size;
    position = Vector2.zero();
  }
}

// 🔹 Score Display
class ScoreDisplay extends TextComponent with HasGameRef<JumpingGame> {

  @override
  Future<void> onLoad() async {
    text = "Score: 0";
    textRenderer = TextPaint(
      style: TextStyle(fontSize: 24, color: Colors.white),
    );
    // Set anchor to topCenter and position with a margin of 20 pixels from the top
    anchor = Anchor.topCenter;
    position = Vector2(gameRef.size.x / 2, 70);
  }

  @override
  void update(double dt) {
    text = gameRef.isGameOver
        ? "Game Over! Final Score: ${gameRef.score}"
        : "Score: ${gameRef.score}";
  }
}

// 🔹 Start Screen
class StartScreen extends PositionComponent with HasGameRef<JumpingGame>, TapCallbacks {
  final VoidCallback onStart;

  StartScreen({required this.onStart});

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    add(
      RectangleComponent(
        size: gameRef.size,
        paint: Paint()..color = Colors.black.withOpacity(0.5),
      ),
    );
    final startButton = StartButton(onStart: onStart);
    add(startButton);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onStart();
  }
}

// 🔹 Start Button
class StartButton extends PositionComponent with TapCallbacks, HasGameRef<JumpingGame> {
  final VoidCallback onStart;

  StartButton({required this.onStart});

  @override
  Future<void> onLoad() async {
    size = Vector2(200, 80);
    position = (gameRef.size / 2) - (size / 2);

    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue,
    ));
    add(TextComponent(
      text: "Start Game",
      position: Vector2(50, 30),
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onStart();
  }
}

// 🔹 Game Over Screen
class GameOverScreen extends PositionComponent with HasGameRef<JumpingGame>, TapCallbacks {
  final int score;

  GameOverScreen({required this.score});

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    // Semi-transparent overlay
    add(RectangleComponent(
      size: gameRef.size,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
    ));
    // Game Over text
    final gameOverText = TextComponent(
      text: "Game Over\nScore: $score\nTap to Restart",
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: gameRef.size / 2,
    );
    add(gameOverText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.resetGame();
  }
}