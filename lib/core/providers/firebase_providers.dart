import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase SDK singletons, exposed as providers so tests can override them
/// with fakes (`fake_cloud_firestore`, `firebase_auth_mocks`).
final Provider<FirebaseAuth> firebaseAuthProvider =
    Provider<FirebaseAuth>((Ref ref) => FirebaseAuth.instance);

final Provider<FirebaseFirestore> firestoreProvider =
    Provider<FirebaseFirestore>((Ref ref) => FirebaseFirestore.instance);

final Provider<FirebaseDatabase> realtimeDatabaseProvider =
    Provider<FirebaseDatabase>((Ref ref) => FirebaseDatabase.instance);

final Provider<FirebaseStorage> firebaseStorageProvider =
    Provider<FirebaseStorage>((Ref ref) => FirebaseStorage.instance);

final Provider<FirebaseMessaging> firebaseMessagingProvider =
    Provider<FirebaseMessaging>((Ref ref) => FirebaseMessaging.instance);

/// Emits whenever the device gains or loses connectivity.
///
/// The offline check-in queue listens to this to know when to replay.
final StreamProvider<bool> isOnlineProvider = StreamProvider<bool>(
  (Ref ref) => Connectivity().onConnectivityChanged.map(
        (List<ConnectivityResult> results) =>
            results.any((ConnectivityResult r) => r != ConnectivityResult.none),
      ),
);
