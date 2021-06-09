part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class PhoneNumberExists extends LoginState {}

class CodeSentState extends LoginState {}

class AccountNotFound extends LoginState {
  final String userType;

  AccountNotFound(this.userType);
}

class PhoneVerified extends LoginState {
  final User user;

  PhoneVerified(this.user);
}

class RiderCreated extends LoginState {
  final Rider rider;

  RiderCreated(this.rider);
}

class UserCreated extends LoginState {
  final User user;

  UserCreated(this.user);
}

class CreateUserError extends LoginState {}

class VerifyingError extends LoginState {}
