import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad_dispatcher/data/models/completed_request.dart';
import 'package:lunad_dispatcher/data/models/rider.dart';
import 'package:lunad_dispatcher/repositories/rider_repository.dart';

part 'rider_event.dart';
part 'rider_state.dart';

class RiderBloc extends Bloc<RiderEvent, RiderState> {
  final riderRepository = RiderRepository();
  StreamSubscription availableRiderStream;
  StreamSubscription riderStream;
  RiderBloc() : super(RiderInitial());

  @override
  Stream<RiderState> mapEventToState(
    RiderEvent event,
  ) async* {
    if (event is StreamRiders) {
      riderStream?.cancel();
      riderStream = riderRepository.streamRiders().listen((riders) {
        add(LoadRiders(riders.toList()));
      });
    }

    if (event is LoadRiders) {
      yield LoadingRiders();
      final riders = event.riders;
      yield LoadedRiders(riders);
    }

    if (event is AssignRider) {
      yield AssigningRider();
      await riderRepository.assignRider(event.requestId, event.rider);
      yield RiderAssigned();
    }

    if (event is SearchRiders) {
      final query = event.query;
      yield SearchingRiders();
      final riders = await riderRepository.getAllRiders();

      if (riders.isEmpty) {
        yield EmptyRiders();
      } else {
        if (query.isEmpty || query == null) {
          yield SearchedRiders(riders);
        } else {
          final filteredRiderList = riders.where((rider) {
            final name = rider.firstName + rider.lastName;
            return name.toLowerCase().contains(query);
          }).toList();
          yield SearchedRiders(filteredRiderList);
        }
      }
    }

    if (event is LoadRiderDetails) {
      yield LoadingRiderDetails();
      final rider = await riderRepository.getRider(event.riderId);
      final completedRequests =
          await riderRepository.getCompletedRequests(event.riderId, event.date);
      yield LoadedRiderDetails(rider, completedRequests);
    }

    if (event is SearchAvailableRiders) {
      final query = event.query;
      yield SearchingAvailableRiders();
      final riders = await riderRepository.getAvailableRiders();
      if (riders.isEmpty)
        yield EmptyAvailableRiders();
      else {
        if (query.isEmpty || query == null)
          yield SearchedAvailableRiders(riders);
        else {
          List<Rider> filteredRiders = riders.where((rider) {
            final name = rider.firstName + rider.lastName;
            return name.toLowerCase().contains(query);
          }).toList();
          yield SearchedAvailableRiders(filteredRiders);
        }
      }
    }
  }

  @override
  Future<void> close() {
    availableRiderStream?.cancel();
    riderStream?.cancel();
    return super.close();
  }
}
