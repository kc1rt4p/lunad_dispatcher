part of 'rider_bloc.dart';

abstract class RiderState extends Equatable {
  const RiderState();

  @override
  List<Object> get props => [];
}

class RiderInitial extends RiderState {}

class LoadedAvailableRiders extends RiderState {
  final List<Rider> riders;

  LoadedAvailableRiders(this.riders);

  @override
  List<Object> get props => [riders];
}

class LoadingRiders extends RiderState {}

class LoadedRiders extends RiderState {
  final List<Rider> riders;

  LoadedRiders(this.riders);

  @override
  List<Object> get props => [riders];
}

class LoadedAllRiders extends RiderState {
  final List<Rider> riders;

  LoadedAllRiders(this.riders);

  @override
  List<Object> get props => [riders];
}

class SearchingAvailableRiders extends RiderState {}

class SearchingRiders extends RiderState {}

class SearchedRiders extends RiderState {
  final List<Rider> riders;

  SearchedRiders(this.riders);

  @override
  List<Object> get props => [riders];
}

class SearchedAvailableRiders extends RiderState {
  final List<Rider> riders;

  SearchedAvailableRiders(this.riders);

  @override
  List<Object> get props => [riders];
}

class LoadingRiderDetails extends RiderState {}

class LoadedRiderDetails extends RiderState {
  final Rider rider;
  final List<CompletedRequest> completedRequests;

  LoadedRiderDetails(this.rider, this.completedRequests);

  @override
  List<Object> get props => [rider, completedRequests];
}

class EmptyAvailableRiders extends RiderState {}

class EmptyRiders extends RiderState {}

class AssigningRider extends RiderState {}

class RiderAssigned extends RiderState {}
