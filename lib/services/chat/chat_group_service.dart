// import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;
// import 'package:http/http.dart' as http;

class ChatGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Gửi thông báo đẩy tới các thành viên nhóm
  // Future<void> _sendGroupPushNotification(
  //   List<String> memberIDs,
  //   String groupName,
  //   String senderName,
  //   String message, {
  //   bool isImage = false,
  // }) async {
  //   const String serverKey = 'YOUR_SERVER_KEY_HERE';

  //   for (final uid in memberIDs) {
  //     if (uid == _auth.currentUser!.uid) continue; // Không gửi cho chính mình

  //     final userDoc = await _firestore.collection('Users').doc(uid).get();
  //     final token = userDoc.data()?['fcmToken'];
  //     if (token == null) continue;

  //     await http.post(
  //       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'key=$serverKey',
  //       },
  //       body: jsonEncode({
  //         "to": token,
  //         "notification": {
  //           "title": "$groupName - $senderName",
  //           "body": isImage ? "đã gửi một hình ảnh" : message,
  //           "sound": "default",
  //         },
  //         "priority": "high",
  //         "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK"},
  //       }),
  //     );
  //   }
  // }

  // Gửi tin nhắn nhóm
  Future<void> sendGroupMessage({
    required String groupID,
    required String message,
    // required List<String> memberIDs,
    // required String groupName,
    bool isImage = false,
  }) async {
    final currentUser = _auth.currentUser!;
    final senderID = currentUser.uid;
    final senderEmail = currentUser.email!;
    final senderDoc = await _firestore.collection('Users').doc(senderID).get();
    final senderData = senderDoc.data();
    final senderName = senderDoc.data()?['username'] ?? 'Người dùng';
    final senderAvatar = senderData?['avatar'] ?? '';

    final Timestamp timestamp = Timestamp.now();
    if (message.trim().isEmpty) return;

    final msgData = {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'message': message,
      'timestamp': timestamp,
      'isImage': isImage,
    };

    await _firestore
        .collection('group_chats')
        .doc(groupID)
        .collection('messages')
        .add(msgData);

    await _firestore
        .collection('group_last_messages')
        .doc(groupID)
        .set(msgData);

    // await _sendGroupPushNotification(
    //   memberIDs,
    //   groupName,
    //   senderName,
    //   message,
    //   isImage: isImage,
    // );
  }

  // Lấy tin nhắn nhóm
  Stream<QuerySnapshot> getGroupMessages(String groupID) {
    return _firestore
        .collection('group_chats')
        .doc(groupID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteGroupMessage({
    required String groupID,
    required String messageID,
  }) async {
    final messageRef = _firestore
        .collection('group_chats')
        .doc(groupID)
        .collection('messages')
        .doc(messageID);

    // Lấy nội dung tin nhắn chuẩn bị xóa
    final messageDoc = await messageRef.get();
    if (!messageDoc.exists) return;

    // final deletedTimestamp = messageDoc.data()?['timestamp'];

    // Xóa tin nhắn
    await messageRef.delete();

    // Kiểm tra nếu đây là tin nhắn cuối cùng thì cập nhật lại group_last_messages
    final messagesSnapshot =
        await _firestore
            .collection('group_chats')
            .doc(groupID)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (messagesSnapshot.docs.isNotEmpty) {
      // Cập nhật tin nhắn cuối cùng mới
      final newLastMessage = messagesSnapshot.docs.first.data();
      await _firestore
          .collection('group_last_messages')
          .doc(groupID)
          .set(newLastMessage);
    } else {
      // Không còn tin nhắn nào -> xóa luôn last_message
      await _firestore.collection('group_last_messages').doc(groupID).delete();
    }
  }

  // Lấy danh sách nhóm người dùng đang tham gia kèm tin nhắn cuối
  Stream<List<Map<String, dynamic>>> getGroupsWithLastMessagesSorted(
    String currentUID,
  ) {
    final groupCollection = _firestore.collection('groups');
    final lastMessagesCollection = _firestore.collection('group_last_messages');

    return Rx.combineLatest2<
      QuerySnapshot,
      QuerySnapshot,
      List<Map<String, dynamic>>
    >(groupCollection.snapshots(), lastMessagesCollection.snapshots(), (
      groupSnap,
      lastMessageSnap,
    ) {
      final groups =
          groupSnap.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .where((group) {
                final members = group['members'] as List<dynamic>? ?? [];
                return members.contains(currentUID);
              })
              .toList();

      final lastMessages = lastMessageSnap.docs;

      for (var group in groups) {
        final groupID = group['id'];
        final matchingDoc =
            lastMessages.where((doc) => doc.id == groupID).isNotEmpty
                ? lastMessages.firstWhere((doc) => doc.id == groupID)
                : null;

        String lastMessage = '';
        String time = '';
        DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(0);

        if (matchingDoc != null) {
          final data = matchingDoc.data() as Map<String, dynamic>;
          final senderID = data['senderID'];
          final messageContent =
              data['isImage'] == true ? '[Hình ảnh]' : (data['message'] ?? '');

          lastMessage =
              senderID == currentUID
                  ? 'Bạn: $messageContent'
                  : '${data['senderName'] ?? 'Người dùng'}: $messageContent';

          final timestamp = data['timestamp'] as Timestamp;
          messageTime = timestamp.toDate();
          timeago.setLocaleMessages('vi', timeago.ViMessages());
          time = timeago.format(messageTime, locale: 'vi');
        }

        group['lastMessage'] = lastMessage;
        group['timeAgo'] = time;
        group['timestamp'] = messageTime;
      }

      groups.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      return groups;
    });
  }
}
