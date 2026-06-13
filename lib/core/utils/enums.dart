class ModeClass {
  static GameModeEnum mode = GameModeEnum.classic;
}

enum GameModeEnum { classic, friendly }

enum UserValidationResult {
  notExists,
  existsAndValidOwner,
  existsButInvalidCountry,
  // existsButInvalidNumber,
  existsName,
  existsNumber,
}
