import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lunad_dispatcher/data/models/completed_request.dart';
import 'package:lunad_dispatcher/data/models/consumer_request.dart';
import 'package:lunad_dispatcher/data/models/delivery_information.dart';
import 'package:lunad_dispatcher/data/models/errand_information.dart';
import 'package:lunad_dispatcher/data/models/rider.dart';
import 'package:lunad_dispatcher/data/models/user.dart';

class RiderRepository {
  final _usersRef = FirebaseFirestore.instance.collection('users');
  final _requestsRef = FirebaseFirestore.instance.collection('requests');
  final _requestsInformationRef =
      FirebaseFirestore.instance.collection('requests_information');

  RiderRepository();

  Future<void> assignRider(String requestId, Rider rider) async {
    try {
      await _requestsRef.doc(requestId).update({
        'status': 'assigned',
        'riderId': rider.id,
        'riderName': '${rider.firstName} ${rider.lastName}',
        'riderPhoneNumber': rider.phoneNum,
        'dateAssigned': FieldValue.serverTimestamp(),
      });

      await _usersRef.doc(rider.id).update({
        'isAvailable': false,
      });
    } catch (e) {
      print('error assigning rider: ${e.toString()}');
    }
  }

  Future<List<Rider>> getAvailableRiders() async {
    final ridersDoc = await _usersRef
        .where('type', isEqualTo: 'rider')
        .where('isAvailable', isEqualTo: true)
        .get();

    return ridersDoc.docs
        .map((riderDoc) => Rider.fromDocument(riderDoc))
        .toList();
  }

  Future<void> updateRiderProfile(User user) async {
    try {
      await _usersRef.doc(user.id).update({
        'displayName': user.displayName,
        'firstName': user.firstName,
        'lastName': user.lastName,
      });
    } catch (e) {
      print('error updating rider profile: ${e.toString()}');
    }
  }

  Future<void> updateRiderLocation(String riderId, List<double> latLng) async {
    try {
      await _usersRef.doc(riderId).update({
        'currentLocation': latLng,
      });
    } catch (e) {
      throw Exception('error updating rider location: ${e.toString()}');
    }
  }

  Stream<ConsumerRequest> streamAssignedRequest(String riderId) {
    return _requestsRef
        .where('riderId', isEqualTo: riderId)
        .where('status', isNotEqualTo: 'completed')
        .limit(1)
        .snapshots()
        .transform(documentToConsumerRequestTransformer);
  }

  Stream<List<Rider>> streamAvailableRiders() {
    return _usersRef
        .where('isAvailable', isEqualTo: true)
        .where('type', isEqualTo: 'rider')
        .snapshots()
        .transform(documentToRiderListTransformer);
  }

  Stream<List<Rider>> streamRiders() {
    return _usersRef
        .where('type', isEqualTo: 'rider')
        .snapshots()
        .transform(documentToRiderListTransformer);
  }

  StreamTransformer documentToRiderListTransformer =
      StreamTransformer<QuerySnapshot, List<Rider>>.fromHandlers(handleData:
          (QuerySnapshot querySnapshot, EventSink<List<Rider>> sink) {
    if (querySnapshot.docs.isNotEmpty) {
      sink.add(
          querySnapshot.docs.map((doc) => Rider.fromDocument(doc)).toList());
    }
  });

  StreamTransformer documentToConsumerRequestTransformer =
      StreamTransformer<QuerySnapshot, ConsumerRequest>.fromHandlers(handleData:
          (QuerySnapshot querySnapshot, EventSink<ConsumerRequest> sink) {
    if (querySnapshot.docs.isNotEmpty) {
      sink.add(ConsumerRequest.fromDocument(querySnapshot.docs[0]));
    }
  });

  Stream<List<double>> streamRiderLocation(riderId) {
    return _usersRef
        .doc(riderId)
        .snapshots()
        .transform(documentToRiderLocTransformer);
  }

  StreamTransformer documentToRiderLocTransformer =
      StreamTransformer<DocumentSnapshot, List<double>>.fromHandlers(
    handleData: (DocumentSnapshot docSnapshot, EventSink<List<double>> sink) {
      final rider = Rider.fromDocument(docSnapshot);
      sink.add(rider.currentLocation);
    },
  );

  Future<Rider> getRider(String riderId) async {
    try {
      final riderDoc = await _usersRef.doc(riderId).get();
      if (!riderDoc.exists) return null;
      return Rider.fromDocument(riderDoc);
    } catch (e) {
      print('error getting rider: ${e.toString()}');
      throw Exception('error getting rider: ${e.toString()}');
    }
  }

  Future<List<Rider>> getAllRiders() async {
    try {
      final ridersDoc = await _usersRef.where('type', isEqualTo: 'rider').get();
      return ridersDoc.docs.map((doc) => Rider.fromDocument(doc)).toList();
    } catch (e) {
      print('error getting riders: ${e.toString()}');
      return null;
    }
  }

  Future<void> setRiderAvailability(String riderId, bool available) async {
    try {
      await _usersRef.doc(riderId).update({
        'isAvailable': available,
      });
    } catch (e) {
      throw Exception('error setting rider as available: ${e.toString()}');
    }
  }

  Future<List<CompletedRequest>> getCompletedRequests(
      String riderId, DateTime date) async {
    if (date == null) {
      date = DateTime.now();
    }
    try {
      final querySnapshot = await _usersRef
          .doc(riderId)
          .collection('completed_requests')
          .where('dateCompleted', isEqualTo: DateFormat.yMd().format(date))
          .get();
      if (querySnapshot.docs.isNotEmpty)
        return querySnapshot.docs
            .map((docSnapshot) => CompletedRequest.fromDocument(docSnapshot))
            .toList();
      else
        return [];
    } catch (e) {
      print('error getting completed requests: ${e.toString()}');
      return null;
    }
  }

  Stream<List<CompletedRequest>> streamCompletedRequests(
      String riderId, DateTime dateTime) {
    return _usersRef
        .doc(riderId)
        .collection('completed_requests')
        .where('dateCompleted', isEqualTo: DateFormat.yMd().format(dateTime))
        .snapshots()
        .transform(documentToCompletedRequestTransformer);
  }

  StreamTransformer documentToCompletedRequestTransformer =
      StreamTransformer<QuerySnapshot, List<CompletedRequest>>.fromHandlers(
          handleData: (QuerySnapshot querySnapshot,
              EventSink<List<CompletedRequest>> sink) {
    if (querySnapshot.docs.isNotEmpty) {
      sink.add(querySnapshot.docs
          .map((doc) => CompletedRequest.fromDocument(doc))
          .toList());
    } else {
      sink.add([]);
    }
  });

  Future<void> riderAcceptRequest(String requestId, String riderId) async {
    try {
      final riderDoc = await _usersRef.doc(riderId).get();
      final rider = Rider.fromDocument(riderDoc);

      await _requestsRef.doc(requestId).update({
        'dateAccepted': FieldValue.serverTimestamp(),
        'riderName': '${rider.firstName} ${rider.lastName}',
        'status': 'accepted',
        'riderPhoneNumber': rider.phoneNum,
      });

      await setRiderAvailability(riderId, false);
    } catch (e) {
      throw Exception('error accepting request: ${e.toString()}');
    }
  }

  Future<void> riderRejectRequest(String requestId) async {
    try {
      await _requestsRef.doc(requestId).update({
        'dateRejected': FieldValue.serverTimestamp(),
        'status': 'processing',
        'riderId': null,
        'riderName': null,
      });
    } catch (e) {}
  }

  Future<void> riderPickedUpRequest(String requestId, String riderId) async {
    try {
      await _requestsRef.doc(requestId).update({
        'dateCompleted': FieldValue.serverTimestamp(),
        'status': 'picked up',
      });
    } catch (e) {
      throw Exception('error updating request: ${e.toString()}');
    }
  }

  Future<void> riderCompleteRequest(String requestId, String riderId) async {
    try {
      await _requestsRef.doc(requestId).update({
        'dateCompleted': FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      final requestDoc = await _requestsRef.doc(requestId).get();
      final request = ConsumerRequest.fromDocument(requestDoc);
      final type = request.type;

      await _requestsRef.doc(requestId).update({
        'totalDuration': request.dateCompleted
            .toDate()
            .difference(request.dateAccepted.toDate())
            .inSeconds,
      });

      DeliveryInformation deliveryInfo;
      ErrandInformation errandInfo;

      if (type == 'delivery') {
        final deliveryInfoDoc =
            await _requestsInformationRef.doc(requestId).get();
        deliveryInfo = DeliveryInformation.fromDocument(deliveryInfoDoc);
      } else {
        final errandInfoDoc =
            await _requestsInformationRef.doc(requestId).get();
        errandInfo = ErrandInformation.fromDocument(errandInfoDoc);
      }

      await _usersRef.doc(riderId).collection('completed_requests').add({
        'requestId': requestId,
        'consumerName': request.consumerName,
        'type': request.type,
        'dateCompleted':
            DateFormat.yMd().format(request.dateCompleted.toDate()),
        'amountCollected':
            type == 'errand' ? errandInfo.totalFee : deliveryInfo.totalAmount,
        'totalDuration': request.totalDuration,
        'totalDistance': request.totalDistance,
        'dispatcherAmount': request.totalAmount * .07,
      });

      await setRiderAvailability(riderId, true);
    } catch (e) {
      throw Exception('error updating request: ${e.toString()}');
    }
  }
}
