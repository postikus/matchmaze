import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'core/game.dart';
import 'core/ui_settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shattermaze',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UISettings.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [UISettings.gradientStartColor, UISettings.gradientEndColor],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MATCHMAZE',
                style: TextStyle(
                  fontSize: UISettings.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: UISettings.titleColor,
                  letterSpacing: UISettings.titleLetterSpacing,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Match & Destroy',
                style: TextStyle(
                  fontSize: UISettings.subtitleFontSize,
                  color: UISettings.subtitleColor,
                  letterSpacing: UISettings.subtitleLetterSpacing,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const GameScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: UISettings.playButtonColor,
                  foregroundColor: UISettings.playButtonTextColor,
                  padding: UISettings.playButtonPadding,
                  textStyle: TextStyle(fontSize: UISettings.playButtonFontSize),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UISettings.playButtonBorderRadius),
                  ),
                ),
                child: const Text('PLAY'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = MatchMazeGame();
    
    return Scaffold(
      backgroundColor: UISettings.backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: UISettings.gameContainerMaxWidth,
                maxHeight: UISettings.gameContainerMaxHeight,
              ),
              child: GameWidget(
                game: game,
                overlayBuilderMap: {
                  'debug': (context, game) {
                    final gameField = (game as MatchMazeGame).gameField;
                    return Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.all(UISettings.gameLogPadding),
                        decoration: BoxDecoration(
                          color: UISettings.gameLogBackgroundColor.withOpacity(UISettings.gameLogOpacity),
                          borderRadius: BorderRadius.circular(UISettings.gameLogBorderRadius),
                        ),
                        child: ValueListenableBuilder<List<String>>(
                          valueListenable: gameField.logNotifier,
                          builder: (context, log, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Game Log:',
                                  style: TextStyle(
                                    color: UISettings.gameLogTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...log.map((entry) => Text(
                                  entry,
                                  style: TextStyle(
                                    color: UISettings.gameLogTextColor,
                                    fontSize: UISettings.gameLogTextSize,
                                  ),
                                )).toList(),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                },
                initialActiveOverlays: const ['debug'],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: UISettings.gameContainerMaxWidth,
              padding: EdgeInsets.all(UISettings.gameContainerPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const StartScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.arrow_back, color: UISettings.backButtonTextColor),
                    label: Text('Back', style: TextStyle(color: UISettings.backButtonTextColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UISettings.backButtonColor,
                      padding: UISettings.backButtonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UISettings.backButtonBorderRadius),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 