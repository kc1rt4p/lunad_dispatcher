part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class SearchingUsers extends UserState {}

class SearchedUsers extends UserState {
  final List<User> users;

  SearchedUsers(this.users);

  @override
  List<Object> get props => [users];
}

class EmptyUsers extends UserState {}

class LoadingUserDetails extends UserState {}

class LoadedUserDetails extends UserState {
  final User user;
  final List<ConsumerRequest> requests;

  LoadedUserDetails(this.user, this.requests);
}
