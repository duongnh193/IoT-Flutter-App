import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import '../models/environment_model.dart';

/// Firebase Realtime Database implementation for environment sensor data
/// Reads from both bedroom/env (temp, hum, lux) and living_room/env (air_quality)
class EnvironmentFirebaseDataSource {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Watch environment data from both bedroom/env and living_room/env in real-time
  Stream<EnvironmentModel> watchEnvironment() {
    // Use StreamController to combine both streams
    final controller = StreamController<EnvironmentModel>();
    
    Map<dynamic, dynamic>? bedroomData;
    Map<dynamic, dynamic>? livingRoomData;
    
    // Helper to emit merged data when both are available
    void emitMerged() {
      if (bedroomData != null || livingRoomData != null) {
        final mergedData = <dynamic, dynamic>{};
        
        // Add bedroom data (temp, hum, lux)
        if (bedroomData != null) {
          mergedData.addAll(bedroomData!);
        }
        
        // Add living_room air_quality
        if (livingRoomData != null && livingRoomData!.containsKey('air_quality')) {
          mergedData['air_quality'] = livingRoomData!['air_quality'];
        }
        
        controller.add(EnvironmentModel.fromFirebase(mergedData));
      }
    }
    
    // Listen to bedroom/env stream
    final bedroomSubscription = _database.child('bedroom/env').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        bedroomData = event.snapshot.value as Map<dynamic, dynamic>;
        emitMerged();
      }
    });
    
    // Listen to living_room/env stream
    final livingRoomSubscription = _database.child('living_room/env').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        livingRoomData = event.snapshot.value as Map<dynamic, dynamic>;
        emitMerged();
      }
    });
    
    // Clean up subscriptions when stream is cancelled
    controller.onCancel = () {
      bedroomSubscription.cancel();
      livingRoomSubscription.cancel();
    };
    
    return controller.stream;
  }

  /// Get environment data once (for initial load)
  Future<EnvironmentModel> getEnvironment() async {
    // Get data from both locations
    final bedroomSnapshot = await _database.child('bedroom/env').get();
    final livingRoomSnapshot = await _database.child('living_room/env').get();
    
    Map<dynamic, dynamic> mergedData = {};
    
    // Parse bedroom/env data
    if (bedroomSnapshot.exists && bedroomSnapshot.value != null) {
      final bedroomData = bedroomSnapshot.value as Map<dynamic, dynamic>;
      mergedData.addAll(bedroomData);
    }
    
    // Parse living_room/env data (air_quality)
    if (livingRoomSnapshot.exists && livingRoomSnapshot.value != null) {
      final livingRoomData = livingRoomSnapshot.value as Map<dynamic, dynamic>;
      if (livingRoomData.containsKey('air_quality')) {
        mergedData['air_quality'] = livingRoomData['air_quality'];
      }
    }
    
    return EnvironmentModel.fromFirebase(mergedData);
  }
}
