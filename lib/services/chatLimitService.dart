// lib/services/chat_limit_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../components/featureFlags.dart';

class ChatLimitService {
  static const int dailyLimit = 5;
  static const String _dateKey = 'ai_chat_date';
  static const String _countKey = 'ai_chat_count';

  // Checks if the user is allowed to send a message
  Future<bool> canSendMessage() async {
    if (!FeatureFlags.enableAiChatLimit) {
      return true;
    }

    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final storedDate = prefs.getString(_dateKey);

    // If it's a new day, reset the count to 0
    if (storedDate != today) {
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_countKey, 0);
      return true;
    }

    // Check current count
    final count = prefs.getInt(_countKey) ?? 0;
    return count < dailyLimit;
  }

  // Increments the count after a successful message
  Future<void> incrementMessageCount() async {
    if (!FeatureFlags.enableAiChatLimit) return;

    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_countKey) ?? 0;
    await prefs.setInt(_countKey, count + 1);
  }
}