import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:chat_app/theme_manager.dart';
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
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/avatar.png'),
                    radius: 20,
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
            Expanded(child: _buildUserList(dark)),
          ],
        );
      },
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
    if (userData['email'] != _authService.getCurrentUser()!.email) {
      return ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
                    receiverName: userData['username'],
                    receiverID: userData['uid'],
                  ),
            ),
          );
        },
        leading: Stack(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar.png'),
                  radius: 16,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
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
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          userData['username'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Halo'),
        trailing: const Text('10:30'),
      );
    } else {
      return Container();
    }
  }
}
