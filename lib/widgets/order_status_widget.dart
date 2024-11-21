import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget orderStatus(String orderStatus) {
  if (orderStatus == 'Pending') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Pending ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Accepted') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Accepted ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Preparing') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Preparing ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Waiting') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Waiting ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Assigned') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Assigned ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Picking up') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Picking up ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Picked up') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Picked up ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Delivering') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Delivering ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Delivered') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Delivered ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Completing') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Completing ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Complete') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Complete ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  return const SizedBox();
}