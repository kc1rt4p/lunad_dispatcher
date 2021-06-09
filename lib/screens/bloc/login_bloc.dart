import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad_dispatcher/data/models/rider.dart';
import 'package:lunad_dispatcher/data/models/user.dart';
import 'package:lunad_dispatcher/repositories/firebase_auth_repository.dart';
import 'package:lunad_dispatcher/repositories/user_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuthRepo _authRepo = FirebaseAuthRepo();
  final UserRepository _userRepo = UserRepository();
  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    yield LoginInitial();

    if (event is LoginReset) {
      yield LoginInitial();
    }

    if (event is SendCode) {
      yield* mapSendCodeState(event);
    }

    if (event is ResendCode) {
      yield* mapResendCodeState(event);
    }

    if (event is VerifyPhoneNumber) {
      yield* mapVerifyPhoneNumberState(event);
    }

    if (event is CreateUser) {
      yield* mapCreateUserState(event);
    }

    if (event is CreateRider) {
      yield* mapCreateRiderState(event);
    }
  }

  Stream<LoginState> mapSendCodeState(LoginEvent event) async* {
    yield LoginLoading();
    await _authRepo.verifyPhoneNumber((event as SendCode).phoneNumber);
    yield CodeSentState();
    //await _userRepo.authenticate((event as SendCode).phoneNumber
  }

  Stream<LoginState> mapVerifyPhoneNumberState(LoginEvent event) async* {
    yield LoginLoading();
    User _user =
        await _authRepo.signInWithSmsCode((event as VerifyPhoneNumber).smsCode);

    if (_user != null) {
      final userExists = await _userRepo.userExists(_user.id);

      if (userExists) {
        yield PhoneNumberExists();
      } else {
        yield PhoneVerified(_user);
      }
    } else {
      yield VerifyingError();
    }
  }

  Stream<LoginState> mapCreateRiderState(LoginEvent event) async* {
    yield LoginLoading();
    User _rider = await _userRepo.createRider((event as CreateRider).user);

    if (_rider != null) {
      yield RiderCreated(_rider);
    } else {
      yield CreateUserError();
    }
  }

  Stream<LoginState> mapCreateUserState(LoginEvent event) async* {
    yield LoginLoading();
    User _user = await _userRepo.createUser((event as CreateUser).user);

    if (_user != null) {
      yield UserCreated(_user);
    } else {
      yield CreateUserError();
    }
  }

  Stream<LoginState> mapResendCodeState(LoginEvent event) async* {
    yield LoginLoading();
    await _authRepo.verifyPhoneNumber((event as ResendCode).phoneNumber);
    yield CodeSentState();
  }
}
