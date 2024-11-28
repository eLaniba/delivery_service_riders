import 'package:delivery_service_riders/global/global.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget orderStatusHelp({required BuildContext context, required String orderStatus}) {
  if (orderStatus == 'Waiting') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16,),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.info(PhosphorIconsStyle.bold),
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8,),
          //Text
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "(1/7) Press ",
                    style: TextStyle(color: gray),
                  ),
                  TextSpan(
                    text: "Accept Order",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray,
                    ),
                  ),
                  TextSpan(
                    text: " to assign yourself as the rider and deliver the order.",
                    style: TextStyle(color: gray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } else if(orderStatus == 'Assigned') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16,),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.info(PhosphorIconsStyle.bold),
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8,),
          //Text
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "(2/7) Press ",
                    style: TextStyle(color: gray),
                  ),
                  TextSpan(
                    text: "Start Pickup Route",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray,
                    ),
                  ),
                  TextSpan(
                    text: " to start your route to the store and pickup the order.",
                    style: TextStyle(color: gray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } else if(orderStatus == 'Picking up') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16,),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.info(PhosphorIconsStyle.bold),
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8,),
          //Text
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "(3/7) Press ",
                    style: TextStyle(color: gray),
                  ),
                  TextSpan(
                    text: "Request Pickup Confirmation",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray,
                    ),
                  ),
                  TextSpan(
                    text: " if you have received the order to start the delivery.",
                    style: TextStyle(color: gray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } else if(orderStatus == 'Picked up') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16,),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.info(PhosphorIconsStyle.bold),
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8,),
          //Text
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "(4/7) Press ",
                    style: TextStyle(color: gray),
                  ),
                  TextSpan(
                    text: "Start Delivery Route",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray,
                    ),
                  ),
                  TextSpan(
                    text: " to start the route to the customer's address.",
                    style: TextStyle(color: gray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } else if(orderStatus == 'Delivering') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16,),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.info(PhosphorIconsStyle.bold),
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8,),
          //Text
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "(5/7) Press ",
                    style: TextStyle(color: gray),
                  ),
                  TextSpan(
                    text: "Request Delivery Confirmation",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray,
                    ),
                  ),
                  TextSpan(
                    text: " if you have successfully deliver the order.",
                    style: TextStyle(color: gray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } else if(orderStatus == 'Delivered') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16,),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.info(PhosphorIconsStyle.bold),
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8,),
          //Text
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "(6/7) Press ",
                    style: TextStyle(color: gray),
                  ),
                  TextSpan(
                    text: "Start Store Route",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray,
                    ),
                  ),
                  TextSpan(
                    text: " to go back to the store to finalize the transaction.",
                    style: TextStyle(color: gray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } else if(orderStatus == 'Completing') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16,),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.info(PhosphorIconsStyle.bold),
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8,),
          //Text
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "(7/7) Press ",
                    style: TextStyle(color: gray),
                  ),
                  TextSpan(
                    text: "Complete Order",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray,
                    ),
                  ),
                  TextSpan(
                    text: " if you have completed the transaction from the store.",
                    style: TextStyle(color: gray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  else {
    return SizedBox();
  }
}