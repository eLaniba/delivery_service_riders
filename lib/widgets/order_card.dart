import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/inProgressScreens/order_details_screen.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:delivery_service_riders/widgets/order_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class OrderCard extends StatelessWidget {
  final NewOrder order;

  OrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.white,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => OrderDetailsScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Order Information
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Order Icon
                  Icon(
                    PhosphorIcons.package(PhosphorIconsStyle.bold),
                    size: 32,
                  ),
                  const SizedBox(width: 8,),
                  //Order Status and Order ID
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Order Status Widget
                        orderStatusWidget(order.orderStatus!),
                        //Order ID
                        Text(
                          order.orderID!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            color: gray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                color: white80,
              ),
              //Store Information
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Store Icon
                    Icon(
                      PhosphorIcons.storefront(PhosphorIconsStyle.regular),
                    ),
                    const SizedBox(width: 8,),
                    //Store Name
                    Flexible(
                      child: Text(
                        order.storeName!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4,),
                    // Store Phone
                    Text(
                      order.storePhone!,
                      style: TextStyle(
                        fontSize: 16,
                        color: gray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              //User Information
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //User Icon
                    Icon(
                      PhosphorIcons.user(PhosphorIconsStyle.regular),
                    ),
                    const SizedBox(width: 8,),
                    //User Name
                    Flexible(
                      child: Text(
                        order.userName!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4,),
                    //User Phone
                    Text(
                      order.userPhone!,
                      style: TextStyle(
                        fontSize: 16,
                        color: gray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              //You have items text
              Text(
                'You have ${order.items!.length} item(s) in this order',
                style: TextStyle(
                  fontSize: 16,
                  color: gray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


