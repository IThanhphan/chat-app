import 'package:chat_app/components/custom_avatar.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:flutter/material.dart';

class DeleteEmployeePage extends StatefulWidget {
  const DeleteEmployeePage({super.key});

  @override
  State<DeleteEmployeePage> createState() => _DeleteEmployeePageState();
}

class _DeleteEmployeePageState extends State<DeleteEmployeePage> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
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

  void _deleteSelectedUsers() async {
    final currentUser = _authService.getCurrentUser();
    final currentUserData = await _chatService.getUserById(currentUser!.uid);

    if (!currentUserData['admin']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không có quyền xóa người dùng')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text(
              'Bạn có chắc chắn muốn xóa các tài khoản đã chọn không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      for (final uid in _selectedUserIds) {
        await _chatService.deleteUser(uid);
      }

      setState(() {
        _selectedUserIds.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa tài khoản thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
    }
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
          backgroundColor: dark ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Xóa tài khoản nhân viên',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Ô tìm kiếm
              Padding(
                padding: const EdgeInsets.all(12),
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

              const Divider(height: 1),

              // Danh sách nhân viên
              Expanded(child: _listUser()),

              // Nút Xóa
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _deleteSelectedUsers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Xóa',
                    style: TextStyle(color: Colors.white),
                  ),
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
                      title: Text(user['username']),
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
