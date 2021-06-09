part of 'dispatcher_bloc.dart';

abstract class DispatcherEvent extends Equatable {
  const DispatcherEvent();

  @override
  List<Object> get props => [];
}

class GetInitialInfo extends DispatcherEvent {
  final String date;

  GetInitialInfo(this.date);
}
