class GameSettings {
  // Grid settings
  static const int gridSize = 8;
  static const double gridSpacing = 5.0;

  // Crystal settings
  static const double crystalSize = 40.0;
  static const double crystalCornerRadius = 8.0;
  static const double crystalGlowRadius = 3.0;
  static const double crystalSelectedOpacity = 0.7;
  static const double crystalMatchedGlowOpacity = 0.5;

  // Animation settings
  static const double animationDuration = 0.3;
  static const double matchEffectDuration = 0.2;
  static const double matchEffectScale = 1.2;
  static const int matchEffectDelay = 300; // milliseconds
  
  // Fall animation settings
  static const double fallAnimationDuration = 0.3;
  static const double fallAnimationCurve = 0.5; // Controls the easing curve (0.0 to 1.0)
  static const double newCrystalStartY = -40.0; // Starting Y position for new crystals
} 