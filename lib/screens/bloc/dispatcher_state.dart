part of 'dispatcher_bloc.dart';

abstract class DispatcherState extends Equatable {
  const DispatcherState();

  @override
  List<Object> get props => [];
}

class DispatcherInitial extends DispatcherState {}

class InitialInfoLoaded extends DispatcherState {
  final int totalRidersCount;
  final int completedRequestsCount;
  final int completedDeliveriesCount;
  final int completedErrandsCount;

  InitialInfoLoaded(
      {this.totalRidersCount,
      this.completedRequestsCount,
      this.completedDeliveriesCount,
      this.completedErrandsCount});

  @override
  List<Object> get props => [
        totalRidersCount,
        completedRequestsCount,
        completedDeliveriesCount,
        completedErrandsCount
      ];
}
