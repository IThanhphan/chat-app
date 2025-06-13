import 'package:chat_app/components/custom_avatar.dart';
import 'package:chat_app/helper/utils/load_asset_image_as_base64.dart';
import 'package:chat_app/helper/utils/show_custom_flushbar.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  // Danh sách chỉ số người dùng đã chọn
  final Set<String> _selectedUserIds = {};

  final List<Map<String, dynamic>> _allUsers = [];
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  List<Map<String, dynamic>> get filteredUsers {
    if (_searchQuery.value.isEmpty) return _allUsers;

    final query = _searchQuery.value.toLowerCase();

    return _allUsers.where((user) {
      final name = (user['username'] as String?)?.toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }

  void createGroup(BuildContext context) async {
    final currentUID = _authService.getCurrentUser()?.uid;
    final selectedUserIds = _selectedUserIds.toList();
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty || selectedUserIds.isEmpty) {
      return showCustomFlushbar(
        context: context,
        text: 'Vui lòng đặt tên nhóm và chọn thành viên.',
        color: Colors.orange.shade600,
        icon: Icons.warning,
      );
    }

    // Đảm bảo người tạo nhóm cũng là thành viên
    if (currentUID != null && !selectedUserIds.contains(currentUID)) {
      selectedUserIds.add(currentUID);
    }

    String base64Image = await loadAssetImageAsBase64(
      'assets/group_avatar.jpg',
    );

    // Tạo nhóm
    final groupRef = await FirebaseFirestore.instance.collection('groups').add({
      'name': groupName,
      'avatar': base64Image,
      'members': selectedUserIds,
      'createdAt': Timestamp.now(),
      'creator': currentUID,
    });

    // Thêm id của nhóm vào chính document vừa tạo (giúp truy vấn dễ hơn)
    await groupRef.update({'id': groupRef.id});

    showCustomFlushbar(
      context: context,
      text: 'Đã tạo nhóm "$groupName"!',
      color: Colors.green.shade600,
      icon: Icons.check_circle,
    );

    _groupNameController.clear();
    _selectedUserIds.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        return Scaffold(
          backgroundColor: dark ? Colors.black : Colors.grey.shade200,
          appBar: AppBar(
            elevation: 1,
            backgroundColor: const Color(0xFF00A8FF),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Tạo nhóm mới',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Ô đặt tên nhóm
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.photo_camera),
                    hintText: 'Đặt tên nhóm',
                    filled: true,
                    fillColor: dark ? Colors.black : Colors.grey.shade200,
                    border: InputBorder.none,
                  ),
                ),
              ),

              // Ô tìm kiếm
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  onChanged: (value) {
                    _searchQuery.value = value;
                  },
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Nhập tên nhân viên',
                    filled: true,
                    fillColor: dark ? Colors.black : Colors.grey.shade200,
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),

              // 👉 Danh sách + Nút tạo nhóm
              Expanded(
                child: Column(
                  children: [
                    // Danh sách thành viên
                    Expanded(child: _listUser()),

                    // 👉 Nút Tạo nhóm
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () => createGroup(context),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Tạo nhóm',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _listUser() {
    final currentUser = _authService.getCurrentUser();

    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, query, _) {
        return StreamBuilder(
          stream: _chatService.getUserStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final users =
                snapshot.data!
                    .where((user) => user['email'] != currentUser?.email)
                    .toList();

            final filtered =
                users.where((user) {
                  final name = user['username']?.toLowerCase() ?? '';
                  return name.contains(query.toLowerCase());
                }).toList();

            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final user = filtered[index];
                final uid = user['uid'];

                return StatefulBuilder(
                  builder: (context, setItemState) {
                    final isSelected = _selectedUserIds.contains(uid);

                    return ListTile(
                      leading: CustomAvatar(
                        imageBase64: user['avatar'] ?? "",
                        radius: 25,
                      ),
                      title: Text(user['username'] ?? ""),
                      trailing: GestureDetector(
                        onTap: () {
                          setItemState(() {
                            if (isSelected) {
                              _selectedUserIds.remove(uid);
                            } else {
                              _selectedUserIds.add(uid);
                            }
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 2),
                            color:
                                isSelected ? Colors.blue : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
