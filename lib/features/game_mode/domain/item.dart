class Item {
  final int? key;
  final String value;
  final bool? isActive;

  Item({this.key, required this.value, this.isActive = false});

  Item copyWith({String? value, bool? isActive}) {
    return Item(
      key: key ?? 0,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    "key": key,
    "value": value,
    "isActive": isActive ?? false,
  };
}
