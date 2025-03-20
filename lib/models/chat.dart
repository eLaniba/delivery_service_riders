import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String? chatId;
  List<String>? participants;
  Map<String, String>? roles;
  Map<String, String>? partnerRoleFor;
  Map<String, String>? participantNames;
  Map<String, String>? participantImageURLs;
  String? lastMessage;
  String? lastSender; // New field for the last sender's ID.
  DateTime? timestamp;
  Map<String, int>? unreadCount;

  Chat({
    this.chatId,
    this.participants,
    this.roles,
    this.partnerRoleFor,
    this.participantNames,
    this.participantImageURLs,
    this.lastMessage,
    this.lastSender,
    this.timestamp,
    this.unreadCount,
  });

  Chat.fromJson(Map<String, dynamic> json) {
    chatId = json['chatId'];
    participants = json['participants'] != null
        ? List<String>.from(json['participants'])
        : [];
    roles = json['roles'] != null
        ? Map<String, String>.from(json['roles'])
        : {};
    partnerRoleFor = json['partnerRoleFor'] != null
        ? Map<String, String>.from(json['partnerRoleFor'])
        : {};
    participantNames = json['participantNames'] != null
        ? Map<String, String>.from(json['participantNames'])
        : {};
    participantImageURLs = json['participantImageURLs'] != null
        ? Map<String, String>.from(json['participantImageURLs'])
        : {};
    lastMessage = json['lastMessage'];
    lastSender = json['lastSender']; // Read the lastSender from JSON.
    if (json['timestamp'] != null) {
      timestamp = (json['timestamp'] as Timestamp).toDate();
    }
    unreadCount = json['unreadCount'] != null
        ? Map<String, int>.from(json['unreadCount'])
        : {};
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (chatId != null) {
      data['chatId'] = chatId;
    }
    data['participants'] = participants;
    data['roles'] = roles;
    data['partnerRoleFor'] = partnerRoleFor;
    data['participantNames'] = participantNames;
    data['participantImageURLs'] = participantImageURLs;
    data['lastMessage'] = lastMessage;
    data['lastSender'] = lastSender; // Write the lastSender.
    data['timestamp'] = timestamp != null ? Timestamp.fromDate(timestamp!) : null;
    data['unreadCount'] = unreadCount;
    return data;
  }
}
