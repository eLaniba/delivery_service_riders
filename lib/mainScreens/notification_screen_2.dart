import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/models/notification_model.dart';
import 'package:delivery_service_riders/services/util.dart';
import 'package:flutter/material.dart';


class NotificationScreen2 extends StatelessWidget {
  final NotificationModel notification;
  final String uid;

  const NotificationScreen2({super.key, required this.notification, required this.uid});

  @override
  Widget build(BuildContext context) {
    // Mark notification as read in Firestore
    FirebaseFirestore.instance
        .collection('riders')
        .doc(uid)
        .collection('notifications')
        .doc(notification.notificationID)
        .update({'read': true});

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [Theme.of(context).primaryColor.withOpacity(0.1), Colors.white],
        //   ),
        // ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'No Title',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notification.body ?? 'No Description',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.access_time,
                    notification.timestamp != null
                        ? orderDateRead(notification.timestamp!.toDate())
                        : 'No Timestamp',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.assignment,
                    notification.orderID!.toUpperCase() ?? 'No Order ID',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.notifications,
                    'Notification type: ${notification.type}' ?? 'No Type',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}