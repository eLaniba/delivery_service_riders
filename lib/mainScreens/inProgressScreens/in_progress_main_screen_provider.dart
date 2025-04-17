import 'package:delivery_service_riders/mainScreens/inProgressScreens/in_progress_main_screen.dart';
import 'package:delivery_service_riders/services/providers/order_stream_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InProgressMainScreenProvider extends StatefulWidget {
  InProgressMainScreenProvider({
    super.key,
    required this.index,
  });

  int index;

  @override
  State<InProgressMainScreenProvider> createState() => _InProgressMainScreenProviderState();
}

class _InProgressMainScreenProviderState extends State<InProgressMainScreenProvider>{

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider(
          create: (_) => OrderStreamProvider.storePickupOrdersStream(),
          initialData: StorePickupOrders([]),
        ),
        StreamProvider(
          create: (_) => OrderStreamProvider.startDeliveryOrdersStream(),
          initialData: StartDeliveryOrders([]),
        ),
        // StreamProvider(
        //   create: (_) => OrderStreamProvider.completingDeliveryOrdersStream(),
        //   initialData: CompletingDeliveryOrders([]),
        // ),
      ],
      child: InProgressMainScreen(index: widget.index),
    );
  }
}
