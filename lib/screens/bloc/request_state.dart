part of 'request_bloc.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object> get props => [];
}

class RequestInitial extends RequestState {}

class LoadedPlacedRequests extends RequestState {
  final List<ConsumerRequest> placedRequests;

  LoadedPlacedRequests(this.placedRequests);

  @override
  List<Object> get props => [placedRequests];
}

class LoadedRequests extends RequestState {
  final List<ConsumerRequest> requests;

  LoadedRequests(this.requests);

  @override
  List<Object> get props => [requests];
}

class AssigningRider extends RequestState {}

class RiderAssigned extends RequestState {}

class LoadingAllRequests extends RequestState {}

class LoadedAllRequests extends RequestState {
  final List<ConsumerRequest> requests;

  LoadedAllRequests(this.requests);
}
