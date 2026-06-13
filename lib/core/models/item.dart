class Item {
  int? key;
  String? value;
  bool? isActive;

  Item({this.key, this.value, this.isActive = false});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      key: json['key'] is int
          ? json['key'] as int
          : int.tryParse(json['key']?.toString() ?? ''),
      value: json['value']?.toString(),
      isActive: json['isActive'] is bool
          ? json['isActive'] as bool
          : json['isActive'].toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'isActive': isActive ?? false,
      };
}
