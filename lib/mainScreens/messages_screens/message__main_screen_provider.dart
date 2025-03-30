import 'package:delivery_service_riders/mainScreens/messages_screens/message_main_screen.dart';
import 'package:delivery_service_riders/services/providers/badge_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageMainScreenProvider extends StatelessWidget {
  const MessageMainScreenProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<StoreMessageCount>(
          create: (_) => BadgeProvider.storeUnreadMessageStream(),
          initialData: StoreMessageCount(0),
        ),
        StreamProvider<UserMessageCount>(
          create: (_) => BadgeProvider.userUnreadMessageStream(),
          initialData: UserMessageCount(0),
        ),
      ],
      child: const MessageMainScreen(),
    );
  }
}
