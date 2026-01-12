part of 'contact_cubit.dart';

/// Base state for contact feature
abstract class ContactState {}

/// Initial state
class ContactInitial extends ContactState {}

/// Loading state when launching URL
class ContactLoading extends ContactState {}

/// Success state after URL is launched
class ContactSuccess extends ContactState {}

/// Error state when URL launch fails
class ContactError extends ContactState {
  final String message;

  ContactError(this.message);
}

