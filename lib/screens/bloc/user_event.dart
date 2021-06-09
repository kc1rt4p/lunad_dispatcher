part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class SearchUsers extends UserEvent {
  final String query;

  SearchUsers(this.query);
}

class LoadUserDetails extends UserEvent {
  final String userId;

  LoadUserDetails(this.userId);
}
