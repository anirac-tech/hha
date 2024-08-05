import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../authentication/domain/app_user.dart';
import '../domain/location.dart';

part 'location_repository.g.dart';

class LocationsRepository {
  const LocationsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String locationPath(String locationId) => 'locations/$locationId';

  static String locationsPath = 'locations';

  Future<void> insertOrUpdate({required UserID uid, required Location location}) =>
      _firestore.doc(locationPath(uid)).set(location.toMap());

  Stream<List<Location>> watchLocations() => queryLocations()
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Query<Location> queryLocations() => _firestore.collection(locationsPath).withConverter(
        fromFirestore: (snapshot, _) => Location.fromMap(snapshot.data()!),
        toFirestore: (location, _) => location.toMap(),
      );

  Future<List<Location>> fetchLocations() async =>
      (await queryLocations().get()).docs.map((doc) => doc.data()).toList();
}

@Riverpod(keepAlive: true)
LocationsRepository locationsRepository(LocationsRepositoryRef ref) =>
    LocationsRepository(FirebaseFirestore.instance);
