import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/environment_firebase_datasource.dart';
import '../domain/entities/environment_entity.dart';

/// Provider for Firebase environment datasource
final environmentFirebaseDataSourceProvider =
    Provider<EnvironmentFirebaseDataSource>((ref) {
  return EnvironmentFirebaseDataSource();
});

/// Provider that watches environment data in real-time
final environmentProvider =
    StreamProvider<EnvironmentEntity>((ref) {
  final dataSource = ref.watch(environmentFirebaseDataSourceProvider);
  
  return dataSource.watchEnvironment().map(
        (model) => model.toEntity(),
      );
});
