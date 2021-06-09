import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lunad_dispatcher/data/models/delivery_information.dart';
import 'package:lunad_dispatcher/data/models/errand_information.dart';
import 'package:lunad_dispatcher/data/models/consumer_request.dart';
import 'package:lunad_dispatcher/data/models/transport_information.dart';

final _requestsRef = FirebaseFirestore.instance.collection('requests');
final _usersRef = FirebaseFirestore.instance.collection('users');
final _requestsInformationRef =
    FirebaseFirestore.instance.collection('requests_information');

class RequestRepository {
  RequestRepository();

  Future<ConsumerRequest> getRequest(String id) async {
    final requestDoc = await _requestsRef.doc(id).get();
    return ConsumerRequest.fromDocument(requestDoc);
  }

  Future<List<ConsumerRequest>> getAllRequests() async {
    final querySnapshot = await _requestsRef.get();
    final requests = <ConsumerRequest>[];
    if (querySnapshot.docs.isEmpty) return [];
    for (var consumerRequestSnapshot in querySnapshot.docs) {
      requests.add(ConsumerRequest.fromDocument(consumerRequestSnapshot));
    }
    return requests;
  }

  Future<void> deleteRequest(ConsumerRequest request) async {
    try {
      if (request.riderId != null) {
        await _usersRef.doc(request.riderId).update({
          'isAvailable': true,
        });
      }

      await _requestsRef.doc(request.id).delete();
    } catch (e) {
      print('error deleting request : ${e.toString()}');
    }
  }

  Stream<List<ConsumerRequest>> streamPlacedRequests() {
    return _requestsRef
        .where('status', isEqualTo: 'placed')
        .snapshots()
        .transform(documentToConsumerRequestListTransformer);
  }

  Stream<ConsumerRequest> getConsumerRequest(String requestId) {
    return _requestsRef
        .doc(requestId)
        .snapshots()
        .transform(documentToConsumerRequestTransformer);
  }

  StreamTransformer documentToConsumerRequestTransformer =
      StreamTransformer<DocumentSnapshot, ConsumerRequest>.fromHandlers(
          handleData:
              (DocumentSnapshot docSnapshot, EventSink<ConsumerRequest> sink) {
    sink.add(ConsumerRequest.fromDocument(docSnapshot));
  });

  Stream<List<ConsumerRequest>> getConsumerRequests(String consumerId) {
    return _requestsRef
        .where('consumerId', isEqualTo: consumerId)
        .where('status', isNotEqualTo: 'completed')
        .snapshots(includeMetadataChanges: true)
        .transform(documentToConsumerRequestListTransformer);
  }

  Future<int> getTotalCompletedRequestsCount(String date) async {
    try {
      final res = await _requestsRef
          .where('status', isEqualTo: 'completed')
          .where('dateCompletedString', isEqualTo: date)
          .get();
      return res.docs.length;
    } catch (e) {
      print('error getting total completedRequests: ${e.toString()}');
      return 0;
    }
  }

  // Future<List<ConsumerRequest>> getAllRequests() async {
  //   try {
  //     final requestDocs = await _requestsRef.get();
  //     return requestDocs.docs
  //         .map((doc) => ConsumerRequest.fromDocument(doc))
  //         .toList();
  //   } catch (e) {}
  // }

  Future<int> getTotalCompletedDeliveriesCount(String date) async {
    try {
      final res = await _requestsRef
          .where('status', isEqualTo: 'completed')
          .where('type', isEqualTo: 'delivery')
          .where('dateCompletedString', isEqualTo: date)
          .get();
      return res.docs.length;
    } catch (e) {
      print('error getting total completedRequests: ${e.toString()}');
      return 0;
    }
  }

  Future<int> getTotalCompletedErrandsCount(String date) async {
    try {
      final res = await _requestsRef
          .where('status', isEqualTo: 'completed')
          .where('type', isEqualTo: 'errand')
          .where('dateCompletedString', isEqualTo: date)
          .get();
      return res.docs.length;
    } catch (e) {
      print('error getting total completedRequests: ${e.toString()}');
      return 0;
    }
  }

  Future<void> updateRequest(String requestId, String status) async {
    try {
      await _requestsRef.doc(requestId).update({
        'status': status,
        'date$status': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('error updating request: ${e.toString()}');
    }
  }

  Future<void> updateRequestRiderLocation(
      String requestId, List<double> latLng) async {
    try {
      await _requestsRef.doc(requestId).update({
        'riderCurrentLocation': latLng,
      });
    } catch (e) {
      throw Exception('error updating request rider location: ${e.toString()}');
    }
  }

  Future<DeliveryInformation> getDeliveryInfo(String requestId) async {
    try {
      final deliveryInfoDoc =
          await _requestsInformationRef.doc(requestId).get();
      final deliveryInfo = DeliveryInformation.fromDocument(deliveryInfoDoc);
      return deliveryInfo;
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }

  Future<ErrandInformation> getErrandInfo(String requestId) async {
    try {
      final errandInfoDoc = await _requestsInformationRef.doc(requestId).get();
      final errandInfo = ErrandInformation.fromDocument(errandInfoDoc);
      return errandInfo;
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }

  StreamTransformer documentToConsumerRequestListTransformer =
      StreamTransformer<QuerySnapshot, List<ConsumerRequest>>.fromHandlers(
          handleData:
              (QuerySnapshot snapshot, EventSink<List<ConsumerRequest>> sink) {
    sink.add(
        snapshot.docs.map((doc) => ConsumerRequest.fromDocument(doc)).toList());
  });

  Stream<DeliveryInformation> getDeliveryInformation(String id) {
    return _requestsInformationRef
        .doc(id)
        .snapshots()
        .transform(documentToDeliveryInformationTransformer);
  }

  StreamTransformer documentToDeliveryInformationTransformer =
      StreamTransformer<DocumentSnapshot, DeliveryInformation>.fromHandlers(
          handleData:
              (DocumentSnapshot snapshot, EventSink<DeliveryInformation> sink) {
    sink.add(DeliveryInformation.fromDocument(snapshot));
  });

  Stream<ErrandInformation> getErrandInformation(String id) {
    return _requestsInformationRef
        .doc(id)
        .snapshots()
        .transform(documentToErrandInformationTransformer);
  }

  StreamTransformer documentToErrandInformationTransformer =
      StreamTransformer<DocumentSnapshot, ErrandInformation>.fromHandlers(
    handleData: (DocumentSnapshot snapshot, EventSink<ErrandInformation> sink) {
      sink.add(ErrandInformation.fromDocument(snapshot));
    },
  );

  Future<List<ErrandItem>> getErrandItems(String requestId) async {
    final docSnapshots =
        await _requestsRef.doc(requestId).collection('errand_items').get();

    return docSnapshots.docs
        .map((doc) => ErrandItem.fromDocument(doc))
        .toList();
  }

  Future<List<ConsumerRequest>> getPastConsumerRequests(
      String consumerId) async {
    final docSnapshots = await _requestsRef
        .where('consumerId', isEqualTo: consumerId)
        .where('status', isEqualTo: 'completed')
        .get();

    return docSnapshots.docs
        .map((doc) => ConsumerRequest.fromDocument(doc))
        .toList();
  }

  Future<List<ConsumerRequest>> getUserRequests(String userId) async {
    try {
      final docSnapshots =
          await _requestsRef.where('consumerId', isEqualTo: userId).get();
      return docSnapshots.docs
          .map((doc) => ConsumerRequest.fromDocument(doc))
          .toList();
    } catch (e) {
      print('error getting user requests: ${e.toString()}');
      return null;
    }
  }

  Stream<TransportInformation> getTransportInformation(String id) {
    return _requestsInformationRef
        .doc(id)
        .snapshots()
        .transform(documentToTransportInformationTransformer);
  }

  StreamTransformer documentToTransportInformationTransformer =
      StreamTransformer<DocumentSnapshot, TransportInformation>.fromHandlers(
          handleData: (DocumentSnapshot snapshot,
              EventSink<TransportInformation> sink) {
    sink.add(TransportInformation.fromDocument(snapshot));
  });

  Future<void> createDeliveryRequest(ConsumerRequest deliveryRequest,
      DeliveryInformation deliveryInformation) async {
    try {
      Map<String, dynamic> deliveryRequestMap = deliveryRequest.toMap();

      deliveryRequestMap['dateRequested'] = FieldValue.serverTimestamp();
      deliveryRequestMap['status'] = 'placed';
      deliveryRequestMap['totalAmount'] = deliveryInformation.totalAmount;

      final consumerRequestReference =
          await _requestsRef.add(deliveryRequestMap);

      final Map<String, dynamic> deliveryInfoMap = deliveryInformation.toMap();

      await _requestsInformationRef
          .doc(consumerRequestReference.id)
          .set(deliveryInfoMap);
    } catch (e) {
      print('Error creating request: ${e.toString()}');
    }
  }

  Future<void> createErrandRequest(
      ConsumerRequest errandRequest,
      ErrandInformation errandInformation,
      List<ErrandItem> itemsToPurchase) async {
    try {
      Map<String, dynamic> errandRequestMap = errandRequest.toMap();
      errandRequestMap['dateRequested'] = FieldValue.serverTimestamp();
      errandRequestMap['status'] = 'placed';
      errandRequestMap['totalAmount'] = errandInformation.totalFee;
      final errandRequestRef = await _requestsRef.add(errandRequestMap);

      final Map<String, dynamic> errandInfoMap = errandInformation.toMap();

      await _requestsInformationRef.doc(errandRequestRef.id).set(errandInfoMap);

      for (var item in itemsToPurchase) {
        await _requestsRef
            .doc(errandRequestRef.id)
            .collection('errand_items')
            .add(item.toMap());
      }
    } catch (e) {
      print('error creating request: ${e.toString()}');
    }
  }

  Future<void> createTransportRequest(ConsumerRequest transportRequest,
      TransportInformation transportInformation) async {
    try {
      Map<String, dynamic> transportRequestMap = transportRequest.toMap();
      transportRequestMap['dateRequested'] = FieldValue.serverTimestamp();
      transportRequestMap['status'] = 'processing';
      final transportRequestRef = await _requestsRef.add(transportRequestMap);

      final Map<String, dynamic> transportInfoMap =
          transportInformation.toMap();

      await _requestsInformationRef
          .doc(transportRequestRef.id)
          .set(transportInfoMap);
    } catch (e) {
      print('error creating request: ${e.toString()}');
    }
  }
}
