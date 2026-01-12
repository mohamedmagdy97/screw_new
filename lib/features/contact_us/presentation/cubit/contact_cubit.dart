import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/features/contact_us/domain/usecases/launch_contact_url_usecase.dart';

part 'contact_state.dart';

/// Cubit for managing contact screen state
class ContactCubit extends Cubit<ContactState> {
  final LaunchContactUrlUseCase _launchContactUrlUseCase;

  ContactCubit({
    required LaunchContactUrlUseCase launchContactUrlUseCase,
  })  : _launchContactUrlUseCase = launchContactUrlUseCase,
        super(ContactInitial());

  /// Launches a contact URL (WhatsApp, LinkedIn, etc.)
  Future<void> launchContactUrl(String url) async {
    emit(ContactLoading());
    try {
      final bool success = await _launchContactUrlUseCase.call(url);
      if (success) {
        emit(ContactSuccess());
      } else {
        emit(ContactError('فشل في فتح الرابط'));
      }
    } catch (e) {
      emit(ContactError('حدث خطأ أثناء محاولة فتح الرابط'));
    }
  }
}

