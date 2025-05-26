import 'package:timeago/timeago.dart' as timeago;
import 'package:chat_app/components/custom_avatar.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 10,
                top: 30,
              ),
              color: const Color(0xFF0099FF),
              child: Row(
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _authService.getUserInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(radius: 20); // loading avatar
                      } else {
                        final avatarBase64 = snapshot.data?['avatar'];
                        return CustomAvatar(
                          imageBase64: avatarBase64,
                          radius: 20,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.search, color: Colors.white),
                ],
              ),
            ),
            _navigationTop(),
            Expanded(child: _buildUserList(dark)),
          ],
        );
      },
    );
  }

  Widget _navigationTop() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: xử lý khi nhấn "Trang chủ"
              },
              icon: const Icon(Icons.home),
              label: const Text("Trang chủ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                // padding: const EdgeInsets.symmetric(vertical: 1),
                // visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const SizedBox(width: 12), // khoảng cách giữa 2 nút
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: xử lý khi nhấn "Nhóm"
              },
              icon: const Icon(Icons.group),
              label: const Text("Nhóm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                // padding: const EdgeInsets.symmetric(vertical: 1),
                // visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(bool dark) {
    return StreamBuilder(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading');
        }

        return ListView(
          children:
              snapshot.data!
                  .map<Widget>(
                    (userData) => _chatListItem(userData, context, dark),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _chatListItem(
    Map<String, dynamic> userData,
    BuildContext context,
    bool dark,
  ) {
    final currentUser = _authService.getCurrentUser();
    if (userData['email'] != currentUser!.email) {
      return StreamBuilder<Map<String, dynamic>?>(
        stream: _chatService.getLastMessage(currentUser.uid, userData['uid']),
        builder: (context, snapshot) {
          String lastMessage = '';
          String time = '';

          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            final senderID = data['senderID'] as String?;
            final messageContent =
                data['isImage'] == true ? '[Hình ảnh]' : data['message'] ?? '';

            if (senderID == currentUser.uid) {
              lastMessage = 'Bạn: $messageContent';
            } else {
              lastMessage = '${userData['username']}: $messageContent';
            }

            final timestamp = data['timestamp'] as Timestamp;
            timeago.setLocaleMessages('vi', timeago.ViMessages());
            final messageTime = timestamp.toDate();
            time = timeago.format(messageTime, locale: 'vi');
          }

          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatPage(
                        receiverName: userData['username'],
                        receiverID: userData['uid'],
                        receiverAvatar: userData['avatar'],
                      ),
                ),
              );
            },
            leading: Stack(
              children: [
                CustomAvatar(imageBase64: userData['avatar'], radius: 25),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dark ? Colors.black : Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              userData['username'],
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(time),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
