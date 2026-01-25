// lib/services/stats_service.dart
import 'package:flutter/foundation.dart';

class StatsService {
  // Singleton
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  // Real-time Counters
  final ValueNotifier<int> sessionCount = ValueNotifier(1); // Starts at 1
  final ValueNotifier<int> queryCount = ValueNotifier(0);

  void incrementQueryCount() {
    queryCount.value++;
  }

  void resetStats() {
    queryCount.value = 0;
    sessionCount.value = 1;
  }
}