import 'package:event_client/event_client/event_client.dart';
import 'package:flutter/material.dart';

///
/// Provides access to the [EventClient] from the flutter [BuildContext]
class EventClientProvider extends InheritedWidget {
  final EventClient client;
  ///
  ///
  EventClientProvider({required this.client, required Widget child}) : super(child: child);

  static EventClient of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EventClientProvider>()!.client;
  }

  @override
  bool updateShouldNotify(EventClientProvider oldWidget) => client != oldWidget.client;
}
