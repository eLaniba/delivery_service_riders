import 'package:delivery_service_riders/mainScreens/main_screen.dart';
import 'package:delivery_service_riders/services/providers/badge_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreenProvider extends StatelessWidget {
  int mainScreenIndex, inProgressScreenIndex;

  MainScreenProvider(
      {required this.mainScreenIndex,
      required this.inProgressScreenIndex,
      super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider(
          create: (_) => BadgeProvider.newDeliveryOrdersStream(),
          initialData: NewDeliveryOrders([]),
        ),
        StreamProvider<InProgressCount>(
          create: (_) => BadgeProvider.inProgressOrderCountStream(),
          initialData: InProgressCount(0),
        ),
        StreamProvider<NotificationCount>(
          create: (_) => BadgeProvider.unreadNotificationCountStream(),
          initialData: NotificationCount(0),
        ),
        StreamProvider<MessageCount>(
          create: (_) => BadgeProvider.unreadMessagesCountStream(),
          initialData: MessageCount(0),
        ),

      ],
      child: MainScreen(mainScreenIndex: mainScreenIndex, inProgressScreenIndex: inProgressScreenIndex),
    );
  }
}
