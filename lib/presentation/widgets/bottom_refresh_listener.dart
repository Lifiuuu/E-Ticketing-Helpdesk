import 'dart:async';
import 'package:flutter/material.dart';

/// Wrap a scrollable (ListView / SingleChildScrollView) with this widget to
/// call [onBottomReached] when the user scrolls to the bottom.
class BottomRefreshListener extends StatefulWidget {
  final Widget child;
  final VoidCallback onBottomReached;
  final Duration cooldown;
  final double threshold;

  const BottomRefreshListener({
    super.key,
    required this.child,
    required this.onBottomReached,
    this.cooldown = const Duration(seconds: 2),
    this.threshold = 20.0,
  });

  @override
  State<BottomRefreshListener> createState() => _BottomRefreshListenerState();
}

class _BottomRefreshListenerState extends State<BottomRefreshListener> {
  Timer? _cooldownTimer;

  bool _isAtBottom(ScrollMetrics metrics) {
    return metrics.pixels >= (metrics.maxScrollExtent - widget.threshold);
  }

  void _tryTrigger(ScrollMetrics metrics) {
    if (_cooldownTimer != null && _cooldownTimer!.isActive) return;
    if (_isAtBottom(metrics)) {
      widget.onBottomReached();
      _cooldownTimer = Timer(widget.cooldown, () {});
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _tryTrigger(notification.metrics);
        } else if (notification is OverscrollNotification) {
          _tryTrigger(notification.metrics);
        }
        return false;
      },
      child: widget.child,
    );
  }
}
