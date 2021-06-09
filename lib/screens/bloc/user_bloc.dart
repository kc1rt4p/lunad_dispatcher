import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad_dispatcher/data/models/consumer_request.dart';
import 'package:lunad_dispatcher/data/models/user.dart';
import 'package:lunad_dispatcher/repositories/request_repository.dart';
import 'package:lunad_dispatcher/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final _userRepo = UserRepository();
  final _requestRepo = RequestRepository();
  UserBloc() : super(UserInitial());

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is SearchUsers) {
      final query = event.query;
      yield SearchingUsers();
      final users = await _userRepo.getAllUsers();

      if (users.isEmpty) {
        yield EmptyUsers();
      } else {
        if (query.isEmpty || query == null) {
          yield SearchedUsers(users);
        } else {
          final filteredUserList = users.where((user) {
            final name = user.firstName + user.lastName;
            return name.toLowerCase().contains(query);
          }).toList();
          yield SearchedUsers(filteredUserList);
        }
      }
    }

    if (event is LoadUserDetails) {
      yield LoadingUserDetails();
      final user = await _userRepo.getUser(event.userId);

      final requests = await _requestRepo.getUserRequests(event.userId);
      yield LoadedUserDetails(user, requests);
    }
  }
}
