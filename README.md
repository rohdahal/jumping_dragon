# Jumping Dragon

Jumping Dragon is a simple 2D game built with Flutter and the Flame game engine. In this game, guide your character as it jumps to avoid turtles and flying turtles, earning points along the way. With intuitive controls and a retro arcade feel, this game is a great introduction to Flutter-based game development.

## Features

- **Simple Gameplay:** Jump to avoid obstacles and earn points.
- **Multiple Obstacles:** Encounter both ground and flying turtles.
- **Score Display:** Ongoing score is displayed centered at the top.
- **Start & Game Over Screens:** Begin or restart the game with a tap.
- **Responsive Controls:** Use keyboard arrow keys for jumping and tap interactions for menus.

## Prerequisites

Before running the project, ensure that you have the following installed:

1. **Flutter SDK:**
    - Follow the official Flutter installation guide for your operating system:  
      [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
    - After installing, verify your setup by running:
      ```bash
      flutter doctor
      ```
    - Update Flutter if necessary:
      ```bash
      flutter upgrade
      ```

2. **IDE:**
    - Use [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/) with the Flutter and Dart plugins installed.

3. **Git:**
    - Ensure Git is installed to clone the repository.

4. **Flame Game Engine:**
    - The Flame package is specified in the `pubspec.yaml` file and will be fetched automatically when you run `flutter pub get`.

5. **Assets:**
    - All necessary asset files (`character.png`, `turtle.png`, `flying_turtle.png`, `background.png`) are included in this repository. No assets are ignored, so after cloning, the project is ready to run.

## Setup and Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/rohdahal/jumping_dragon.git
   cd jumping_dragon