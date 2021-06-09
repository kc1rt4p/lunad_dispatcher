import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad_dispatcher/data/models/consumer_request.dart';
import 'package:lunad_dispatcher/data/models/rider.dart';
import 'package:lunad_dispatcher/repositories/request_repository.dart';

part 'request_event.dart';
part 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final requestRepository = RequestRepository();
  StreamSubscription placedRequestsStream;
  RequestBloc() : super(RequestInitial());

  @override
  Stream<RequestState> mapEventToState(
    RequestEvent event,
  ) async* {
    if (event is GetAllRequests) {
      yield LoadingAllRequests();

      final requests = await requestRepository.getAllRequests();

      yield LoadedAllRequests(requests);
    }

    if (event is StreamPlacedRequests) {
      placedRequestsStream?.cancel();
      placedRequestsStream =
          requestRepository.streamPlacedRequests().listen((requests) {
        add(LoadPlacedRequests(requests));
      });
    }

    if (event is LoadPlacedRequests) {
      yield LoadedPlacedRequests(event.placedRequests);
    }

    if (event is LoadRequests) {
      try {
        final requests = await requestRepository.getAllRequests();
        yield LoadedRequests(requests);
      } catch (e) {
        print('error getting requests: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> close() {
    placedRequestsStream?.cancel();
    return super.close();
  }
}
