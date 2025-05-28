import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tuple/tuple.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(
    String receiverID,
    message, {
    bool isImage = false,
  }) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
      isImage: isImage,
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    // add new message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());

    await _firestore
        .collection('last_messages')
        .doc(chatRoomID)
        .set(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatroomID = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatroomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // delete messages
  Future<void> deleteMessage(
    String userID,
    String otherUserID,
    String messageID,
  ) async {
    // Tạo chatRoomID
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    final messagesRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages');

    // Lấy thông tin của tin nhắn cần xóa
    final deletedMessageSnapshot = await messagesRef.doc(messageID).get();
    if (!deletedMessageSnapshot.exists) return;

    // Xóa tin nhắn
    await messagesRef.doc(messageID).delete();

    // Kiểm tra nếu nó là last_message hiện tại
    final lastMessageDoc =
        await _firestore.collection('last_messages').doc(chatRoomID).get();

    if (lastMessageDoc.exists &&
        lastMessageDoc.data()?['timestamp'] ==
            deletedMessageSnapshot.data()?['timestamp']) {
      // Nếu đúng là last message, tìm tin nhắn gần nhất còn lại
      final remainingMessages =
          await messagesRef
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (remainingMessages.docs.isNotEmpty) {
        // Cập nhật lại last_messages
        await _firestore
            .collection('last_messages')
            .doc(chatRoomID)
            .set(remainingMessages.docs.first.data());
      } else {
        // Nếu không còn tin nhắn nào -> xóa last_messages
        await _firestore.collection('last_messages').doc(chatRoomID).delete();
      }
    }
  }

  Stream<Map<String, dynamic>?> getLastMessage(
    String currentUserId,
    String otherUserId,
  ) {
    // construct chatRoomID
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.first.data();
          } else {
            return null;
          }
        });
  }

  Stream<List<Map<String, dynamic>>> getUsersWithLastMessagesSorted(
    String currentUID,
  ) {
    final userCollection = _firestore.collection('Users');
    final lastMessagesCollection = _firestore.collection('last_messages');

    return Rx.combineLatest2<
      QuerySnapshot,
      QuerySnapshot,
      Tuple2<QuerySnapshot, QuerySnapshot>
    >(
      userCollection.snapshots(),
      lastMessagesCollection.snapshots(),
      (userSnap, lastMessageSnap) => Tuple2(userSnap, lastMessageSnap),
    ).map((combined) {
      final userSnap = combined.item1;
      final lastMessageSnap = combined.item2;

      final users =
          userSnap.docs
              .map(
                (doc) => {'uid': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .where((user) => user['uid'] != currentUID)
              .toList();

      final lastMessages = lastMessageSnap.docs;

      List<Map<String, dynamic>> result = [];

      for (final user in users) {
        final otherUID = user['uid'];

        // Tạo chatRoomID
        List<String> ids = [currentUID, otherUID];
        ids.sort();
        String chatRoomID = ids.join('_');

        final matchingDocs = lastMessages.where((doc) => doc.id == chatRoomID);
        final lastMessageDoc =
            matchingDocs.isNotEmpty ? matchingDocs.first : null;

        String lastMessage = '';
        String time = '';
        DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(0);

        if (lastMessageDoc != null) {
          final data = lastMessageDoc.data() as Map<String, dynamic>;
          final senderID = data['senderID'];
          final messageContent =
              data['isImage'] == true ? '[Hình ảnh]' : (data['message'] ?? '');

          lastMessage =
              senderID == currentUID
                  ? 'Bạn: $messageContent'
                  : '${user['username']}: $messageContent';

          final timestamp = data['timestamp'] as Timestamp;
          messageTime = timestamp.toDate();

          timeago.setLocaleMessages('vi', timeago.ViMessages());
          time = timeago.format(messageTime, locale: 'vi');
        }

        result.add({
          ...user,
          'lastMessage': lastMessage,
          'timeAgo': time,
          'timestamp': messageTime,
        });
      }

      // Sắp xếp giảm dần theo thời gian
      result.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      return result;
    });
  }
}
