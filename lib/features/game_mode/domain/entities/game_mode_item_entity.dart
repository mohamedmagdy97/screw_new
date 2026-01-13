class GameModeItemEntity {
  final int key;
  final String value;
  final bool isActive;

  GameModeItemEntity({
    required this.key,
    required this.value,
    this.isActive = false,
  });

  GameModeItemEntity copyWith({
    int? key,
    String? value,
    bool? isActive,
  }) {
    return GameModeItemEntity(
      key: key ?? this.key,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
    );
  }
}

