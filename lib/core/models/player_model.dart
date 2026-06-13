class PlayerModel {
  int? id;
  String? name;
  String? gw1;
  String? gw2;
  String? gw3;
  String? gw4;
  String? gw5;
  String? total;
  bool? isActive;
  bool? isFavorite;
  List<String?> scores;
  List<int> roundScores;

  PlayerModel({
    this.id,
    this.name,
    this.gw1 = '',
    this.gw2 = '',
    this.gw3 = '',
    this.gw4 = '',
    this.gw5 = '',
    this.total = '0',
    this.isActive = false,
    this.isFavorite = false,
    int rounds = 5,
  }) : scores = List.filled(5, null),
       roundScores = List.generate(rounds, (_) => 0);

  int get totalScore => roundScores.reduce((a, b) => a + b);

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
    id: json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? ''),
    name: json['name']?.toString(),
    gw1: json['gw1']?.toString(),
    gw2: json['gw2']?.toString(),
    gw3: json['gw3']?.toString(),
    gw4: json['gw4']?.toString(),
    gw5: json['gw5']?.toString(),
    total: json['total']?.toString(),
    isActive: json['isActive'] is bool
        ? json['isActive'] as bool
        : json['isActive'].toString().toLowerCase() == 'true',

    isFavorite: json['isFavorite'] is bool
        ? json['isFavorite'] as bool
        : json['isFavorite'].toString().toLowerCase() == 'true',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'gw1': gw1,
    'gw2': gw2,
    'gw3': gw3,
    'gw4': gw4,
    'gw5': gw5,
    'total': total,
    'isActive': isActive ?? false,
    'isFavorite': isFavorite ?? false,
  };

  // New method to get round score dynamically
  String getRoundScore(int round) {
    switch (round) {
      case 1:
        return gw1 ?? '';
      case 2:
        return gw2 ?? '';
      case 3:
        return gw3 ?? '';
      case 4:
        return gw4 ?? '';
      case 5:
        return gw5 ?? '';
      default:
        return '';
    }
  }

  // Get score of a specific round
  String? getRoundTeamScore(int round) {
    return scores[round - 1]; // Index is round - 1 since lists start from 0
  }

  // Update score for a specific round
  // void updateScore(int round, String score) {
  //   scores[round - 1] = score;
  //   total = scores
  //       .fold<int>(0, (sum, score) => sum + (int.tryParse(score ?? "0") ?? 0))
  //       .toString();
  // }

  void updateScore(int round, int score) {
    if (round >= 0 && round < roundScores.length) {
      roundScores[round] = score;
    }
  }

  // ===== منطق احتساب الجولات (Screw) =====
  // الجولات الخمس مرتّبة: الفهرس 0..4 يقابل gw1..gw5.

  /// قيم الجولات الخمس بالترتيب.
  List<String> get roundValues => [
    gw1 ?? '',
    gw2 ?? '',
    gw3 ?? '',
    gw4 ?? '',
    gw5 ?? '',
  ];

  void _setRoundValue(int index, String value) {
    switch (index) {
      case 0:
        gw1 = value;
      case 1:
        gw2 = value;
      case 2:
        gw3 = value;
      case 3:
        gw4 = value;
      case 4:
        gw5 = value;
    }
  }

  int get _firstEmptyRoundIndex => roundValues.indexWhere((v) => v.isEmpty);

  int get _lastFilledRoundIndex {
    final values = roundValues;
    for (var i = values.length - 1; i >= 0; i--) {
      if (values[i].isNotEmpty) return i;
    }
    return -1;
  }

  /// عدد الجولات المُدخلة حتى الآن.
  int get filledRoundsCount => roundValues.where((v) => v.isNotEmpty).length;

  /// هل اكتملت كل جولات اللاعب الخمس؟
  bool get isComplete => _firstEmptyRoundIndex < 0;

  /// يعيد احتساب المجموع من قيم الجولات المُدخلة.
  void recomputeTotal() {
    total = roundValues
        .where((v) => v.isNotEmpty)
        .map((v) => int.tryParse(v) ?? 0)
        .fold<int>(0, (a, b) => a + b)
        .toString();
  }

  /// يضيف نتيجة في أول جولة فارغة ثم يحدّث المجموع.
  /// يعيد false إذا كانت كل الجولات ممتلئة.
  bool addRoundScore(int value) {
    final index = _firstEmptyRoundIndex;
    if (index < 0) return false;
    _setRoundValue(index, value.toString());
    recomputeTotal();
    return true;
  }

  /// يعدّل آخر جولة تم إدخالها ثم يحدّث المجموع.
  bool editLastRoundScore(int value) {
    final index = _lastFilledRoundIndex;
    if (index < 0) return false;
    _setRoundValue(index, value.toString());
    recomputeTotal();
    return true;
  }

  /// يصفّر كل جولات اللاعب والمجموع (لإعادة بدء الجولة).
  void resetRounds() {
    gw1 = '';
    gw2 = '';
    gw3 = '';
    gw4 = '';
    gw5 = '';
    total = '0';
  }
}

class TeamModel {
  final String name;
  final PlayerModel player1;
  final PlayerModel player2;

  TeamModel({required this.name, required this.player1, required this.player2});

  int get totalTeamScore => player1.totalScore + player2.totalScore;
}
