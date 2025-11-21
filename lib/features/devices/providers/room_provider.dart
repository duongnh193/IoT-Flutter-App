import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomListProvider = Provider<List<String>>((_) {
  return const [
    'Phòng khách',
    'Phòng ngủ chính',
    'Bếp',
    'Ban công',
    'Garage',
  ];
});
