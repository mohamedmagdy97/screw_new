import 'package:equatable/equatable.dart';

/// ما نعرفه عن طلبات التقييم على الجهاز (محفوظ محليًا، من غير بيانات شخصية).
class ReviewState extends Equatable {
  const ReviewState({
    this.finishedGames = 0,
    this.timesAsked = 0,
    this.lastAskedAt,
  });

  /// عدد الجولات اللي اتحفظت لحد آخرها.
  final int finishedGames;

  /// عدد المرات اللي طلبنا فيها نافذة التقييم.
  final int timesAsked;
  final DateTime? lastAskedAt;

  ReviewState copyWith({
    int? finishedGames,
    int? timesAsked,
    DateTime? lastAskedAt,
  }) {
    return ReviewState(
      finishedGames: finishedGames ?? this.finishedGames,
      timesAsked: timesAsked ?? this.timesAsked,
      lastAskedAt: lastAskedAt ?? this.lastAskedAt,
    );
  }

  @override
  List<Object?> get props => [finishedGames, timesAsked, lastAskedAt];
}
