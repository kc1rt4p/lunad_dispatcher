import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CompletedRequest extends Equatable {
  final String id;
  final String consumerName;
  final String type;
  final double amountCollected;
  final int totalDuration;
  final String dateCompleted;
  final String requestId;
  final double totalDistance;
  final double dispatcherAmount;

  CompletedRequest({
    this.id,
    this.consumerName,
    this.type,
    this.amountCollected,
    this.totalDuration,
    this.dateCompleted,
    this.requestId,
    this.totalDistance,
    this.dispatcherAmount,
  });

  factory CompletedRequest.fromDocument(DocumentSnapshot doc) {
    final docData = doc.data();
    return CompletedRequest(
      id: doc.id,
      consumerName: docData['consumerName'],
      type: docData['type'],
      amountCollected: docData['amountCollected'],
      totalDuration: docData['totalDuration'],
      dateCompleted: docData['dateCompleted'],
      requestId: docData['requestId'],
      totalDistance: docData['totalDistance'],
      dispatcherAmount: docData['dispatcherAmount'],
    );
  }

  @override
  List<Object> get props => [
        id,
        consumerName,
        type,
        amountCollected,
        totalDuration,
        dateCompleted,
        requestId,
        totalDistance,
        dispatcherAmount,
      ];
}
