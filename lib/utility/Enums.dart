class ModeClass {
  static GameMode mode = GameMode.classic;
}

enum GameMode { classic, friendly }

enum UserValidationResult {
  notExists,
  existsAndValidOwner,
  existsButInvalidCountry,
  // existsButInvalidNumber,
  existsName,
  existsNumber,
}
