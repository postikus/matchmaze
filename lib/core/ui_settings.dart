import 'package:flutter/material.dart';

class UISettings {
  // Game container settings
  static const double gameContainerMaxWidth = 800.0;
  static const double gameContainerMaxHeight = 800.0;
  static const double gameContainerPadding = 20.0;

  // Back button settings
  static const EdgeInsets backButtonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const double backButtonBorderRadius = 20.0;
  static const Color backButtonColor = Colors.deepPurple;
  static const Color backButtonTextColor = Colors.white;

  // Game log settings
  static const double gameLogPadding = 8.0;
  static const double gameLogBorderRadius = 8.0;
  static const double gameLogOpacity = 0.7;
  static const double gameLogTextSize = 12.0;
  static const Color gameLogBackgroundColor = Colors.black;
  static const Color gameLogTextColor = Colors.white;

  // Start screen settings
  static const double titleFontSize = 48.0;
  static const double subtitleFontSize = 24.0;
  static const double titleLetterSpacing = 4.0;
  static const double subtitleLetterSpacing = 2.0;
  static const Color titleColor = Colors.white;
  static const Color subtitleColor = Colors.purple;
  static const EdgeInsets playButtonPadding = EdgeInsets.symmetric(horizontal: 48, vertical: 16);
  static const double playButtonFontSize = 24.0;
  static const double playButtonBorderRadius = 30.0;
  static const Color playButtonColor = Colors.deepPurple;
  static const Color playButtonTextColor = Colors.white;

  // Background settings
  static const Color backgroundColor = Colors.black;
  static const Color gradientStartColor = Color(0xFF2A0E61);
  static const Color gradientEndColor = Colors.black;
} 