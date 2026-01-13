part of 'contact_cubit.dart';

abstract class ContactState {}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactSuccess extends ContactState {}

class ContactError extends ContactState {
  final String message;

  ContactError(this.message);
}

