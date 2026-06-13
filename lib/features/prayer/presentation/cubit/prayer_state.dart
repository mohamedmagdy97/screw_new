part of 'prayer_cubit.dart';

enum PrayerStatus { loading, loaded, error }

class PrayerState extends Equatable {
  const PrayerState({
    this.status = PrayerStatus.loading,
    this.prayerTimes,
    this.errorMessage = '',
    this.isOnline = true,
    required this.selectedCity,
  });

  final PrayerStatus status;
  final PrayerTimeModel? prayerTimes;
  final String errorMessage;
  final bool isOnline;
  final CountryModel selectedCity;

  PrayerState copyWith({
    PrayerStatus? status,
    PrayerTimeModel? prayerTimes,
    String? errorMessage,
    bool? isOnline,
    CountryModel? selectedCity,
  }) {
    return PrayerState(
      status: status ?? this.status,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      errorMessage: errorMessage ?? this.errorMessage,
      isOnline: isOnline ?? this.isOnline,
      selectedCity: selectedCity ?? this.selectedCity,
    );
  }

  @override
  List<Object?> get props => [
    status,
    prayerTimes,
    errorMessage,
    isOnline,
    selectedCity,
  ];
}
