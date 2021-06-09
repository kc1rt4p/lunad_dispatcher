part of 'rider_bloc.dart';

abstract class RiderEvent extends Equatable {
  const RiderEvent();

  @override
  List<Object> get props => [];
}

class StreamAvailableRiders extends RiderEvent {}

class StreamRiders extends RiderEvent {}

class LoadAvailableRiders extends RiderEvent {
  final List<Rider> riders;

  LoadAvailableRiders(this.riders);
}

class LoadRiders extends RiderEvent {
  final List<Rider> riders;

  LoadRiders(this.riders);
}

class LoadAllRiders extends RiderEvent {
  final List<Rider> riders;

  LoadAllRiders(this.riders);
}

class SearchAvailableRiders extends RiderEvent {
  final String query;

  SearchAvailableRiders(this.query);
}

class AssignRider extends RiderEvent {
  final String requestId;
  final Rider rider;

  AssignRider(this.requestId, this.rider);
}

class LoadRiderDetails extends RiderEvent {
  final String riderId;
  final DateTime date;

  LoadRiderDetails(this.riderId, this.date);
}

class SearchRiders extends RiderEvent {
  final String query;

  SearchRiders(this.query);
}
