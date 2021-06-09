part of 'request_bloc.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object> get props => [];
}

class StreamPlacedRequests extends RequestEvent {}

class LoadPlacedRequests extends RequestEvent {
  final List<ConsumerRequest> placedRequests;

  LoadPlacedRequests(this.placedRequests);
}

class LoadRequests extends RequestEvent {}

class AssignRider extends RequestEvent {
  final String requestId;
  final Rider rider;

  AssignRider(this.requestId, this.rider);
}

class GetAllRequests extends RequestEvent {}
