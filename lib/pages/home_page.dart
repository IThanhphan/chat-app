import 'package:chat_app/components/custom_avatar.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  bool isHomeSelected = true;

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
            _horizontalUserList(),
            _navigationTop(),
            Expanded(
              child:
                  isHomeSelected ? _buildUserList(dark) : _buildGroupList(dark),
            ),
          ],
        );
      },
    );
  }

  Widget _horizontalUserList() {
    final currentUser = _authService.getCurrentUser();

    return SizedBox(
      height: 90,
      child: StreamBuilder(
        stream: _chatService.getUserStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          final users =
              snapshot.data!
                  .where((user) => user['email'] != currentUser?.email)
                  .toList();

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatPage(
                            receiverName: user['username'],
                            receiverID: user['uid'],
                            receiverAvatar: user['avatar'],
                          ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    CustomAvatar(imageBase64: user['avatar'], radius: 25),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 60,
                      child: Text(
                        user['username'],
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _navigationTop() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isHomeSelected = true;
                });
              },
              icon: const Icon(Icons.person, size: 18),
              label: const Text("Nhân viên", style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(25),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                elevation: isHomeSelected ? 1 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isHomeSelected = false;
                });
              },
              icon: const Icon(Icons.group, size: 18),
              label: const Text("Nhóm", style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(25),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                elevation: isHomeSelected ? 0 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(bool dark) {
    return Center(
      child: Text(
        'Danh sách nhóm đang phát triển...',
        style: TextStyle(
          color: dark ? Colors.white70 : Colors.black54,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildUserList(bool dark) {
    final currentUser = _authService.getCurrentUser();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersWithLastMessagesSorted(currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Lỗi');
        if (!snapshot.hasData) return const Text('Đang tải...');

        final sortedUsers = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: sortedUsers.length,
          itemBuilder: (context, index) {
            final user = sortedUsers[index];
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChatPage(
                          receiverName: user['username'],
                          receiverID: user['uid'],
                          receiverAvatar: user['avatar'],
                        ),
                  ),
                );
              },
              leading: Stack(
                children: [
                  CustomAvatar(imageBase64: user['avatar'], radius: 25),
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
                user['username'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                user['lastMessage'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(user['timeAgo'] ?? ''),
            );
          },
        );
      },
    );
  }
}
