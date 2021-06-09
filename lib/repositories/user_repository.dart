import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lunad_dispatcher/data/models/rider.dart';
import 'package:lunad_dispatcher/data/models/user.dart';

final _usersRef = FirebaseFirestore.instance.collection('users');

class UserRepository {
  UserRepository();

  Future<User> getUser(String id) async {
    try {
      final userDoc = await _usersRef.doc(id).get();
      if (!userDoc.exists) return null;
      return User.fromDocument(userDoc);
    } catch (e) {
      print('error getting user info: ${e.toString()}');
      return null;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final usersDoc =
          await _usersRef.where('type', isEqualTo: 'consumer').get();
      return usersDoc.docs.map((doc) => User.fromDocument(doc)).toList();
    } catch (e) {
      print('error getting users: ${e.toString()}');
      return null;
    }
  }

  Future<int> getTotalRidersCount() async {
    try {
      final riderDocs = await _usersRef.where('type', isEqualTo: 'rider').get();
      return riderDocs.docs.length;
    } catch (e) {
      print('error getting total number of rider: ${e.toString()}');
      return 0;
    }
  }

  Future<Rider> getRider(String id) async {
    try {
      final riderDoc = await _usersRef.doc(id).get();
      if (!riderDoc.exists) return null;
      return Rider.fromDocument(riderDoc);
    } catch (e) {
      print('error getting rider: ${e.toString()}');
      return null;
    }
  }

  Future<bool> userExists(String id) async {
    try {
      final result = await _usersRef.doc(id).get();
      return result.exists;
    } catch (e) {
      print('error check if user exists: ${e.toString()}');
      return null;
    }
  }

  Future<Rider> createRider(User user) async {
    try {
      await _usersRef.doc(user.id).set({
        'type': 'rider',
        'displayName': user.displayName,
        'phoneNum': user.phoneNum,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'dateCreated': FieldValue.serverTimestamp(),
        'currentLocation': null,
        'isAvailable': false,
      });

      final riderDoc = await _usersRef.doc(user.id).get();
      if (!riderDoc.exists) return null;
      return Rider.fromDocument(riderDoc);
    } catch (e) {
      print('error creating rider: ${e.toString()}');
      return null;
    }
  }

  Future<User> createUser(User user) async {
    try {
      await _usersRef.doc(user.id).set({
        'type': user.type,
        'displayName': user.displayName,
        'phoneNum': user.phoneNum,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'dateCreated': FieldValue.serverTimestamp(),
      });
      final userDoc = await _usersRef.doc(user.id).get();
      if (!userDoc.exists) return null;
      return User.fromDocument(userDoc);
    } catch (e) {
      print('error creating user: ${e.toString()}');
      return null;
    }
  }
}
