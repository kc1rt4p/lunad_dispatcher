import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad_dispatcher/repositories/request_repository.dart';
import 'package:lunad_dispatcher/repositories/rider_repository.dart';
import 'package:lunad_dispatcher/repositories/user_repository.dart';

part 'dispatcher_event.dart';
part 'dispatcher_state.dart';

class DispatcherBloc extends Bloc<DispatcherEvent, DispatcherState> {
  final riderRepository = RiderRepository();
  final userRepository = UserRepository();
  final requestRepository = RequestRepository();

  DispatcherBloc() : super(DispatcherInitial());

  @override
  Stream<DispatcherState> mapEventToState(
    DispatcherEvent event,
  ) async* {
    if (event is GetInitialInfo) {
      print(event.date);
      var totalRiders = 0;
      var completedRequests = 0;
      var completedDeliveries = 0;
      var completedErrands = 0;

      totalRiders += await userRepository.getTotalRidersCount();
      completedRequests +=
          await requestRepository.getTotalCompletedRequestsCount(event.date);
      completedDeliveries +=
          await requestRepository.getTotalCompletedDeliveriesCount(event.date);
      completedErrands +=
          await requestRepository.getTotalCompletedErrandsCount(event.date);

      yield InitialInfoLoaded(
        totalRidersCount: totalRiders,
        completedRequestsCount: completedRequests,
        completedDeliveriesCount: completedDeliveries,
        completedErrandsCount: completedErrands,
      );
    }
  }
}
