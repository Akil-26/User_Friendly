import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final List<String> interests;

  AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    this.interests = const [],
  });

  @override
  List<Object?> get props => [name, email, password, interests];
}

class AuthCheckRequested extends AuthEvent {} // check if already logged in

class AuthLogoutRequested extends AuthEvent {}

class AuthInterestsUpdated extends AuthEvent {
  final List<String> interests;
  AuthInterestsUpdated(this.interests);

  @override
  List<Object?> get props => [interests];
}

class AuthPasswordChangeRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  AuthPasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class AuthAccountDeleteRequested extends AuthEvent {
  final String password;
  AuthAccountDeleteRequested(this.password);

  @override
  List<Object?> get props => [password];
}
