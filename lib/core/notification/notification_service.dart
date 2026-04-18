import 'dart:async';
import 'package:flutter/material.dart';

class NotificationEntry {
  final int ticketId;
  final String message;
  NotificationEntry({required this.ticketId, required this.message});
}

class NotificationService extends ChangeNotifier {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  NotificationEntry? _current;
  Timer? _dismissTimer;

  NotificationEntry? get current => _current;

  void showNotification(int ticketId, String message, {Duration duration = const Duration(seconds: 4)}) {
    _dismissTimer?.cancel();
    _current = NotificationEntry(ticketId: ticketId, message: message);
    notifyListeners();
    _dismissTimer = Timer(duration, () {
      _current = null;
      notifyListeners();
    });
  }

  void clear() {
    _dismissTimer?.cancel();
    _current = null;
    notifyListeners();
  }
}
