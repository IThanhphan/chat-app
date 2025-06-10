import 'dart:convert';
import 'package:chat_app/helper/utils/load_asset_image_as_base64.dart';
import 'package:chat_app/pages/receiver_info_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_group_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:image_picker/image_picker.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupID;
  final String groupName;
  final String groupAvatar;
  final String groupCreator;

  const GroupInfoPage({
    super.key,
    required this.groupID,
    required this.groupName,
    required this.groupAvatar,
    required this.groupCreator,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final ChatGroupService _groupChatService = ChatGroupService();
  final AuthService _authService = AuthService();

  void deleteMember(Map<String, dynamic> member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: Text(
              'Bạn có chắc muốn xóa ${member['username']} khỏi nhóm?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _groupChatService.removeMemberFromGroup(
        widget.groupID,
        member['uid'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member['username']} đã bị xóa khỏi nhóm')),
      );
    }
  }

  void leaveGroup() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận rời nhóm'),
            content:
                widget.groupCreator == currentUser.uid
                    ? const Text(
                      'Bạn là người tạo nhóm. Nếu bạn rời đi, nhóm sẽ bị xóa. Bạn chắc chứ?',
                    )
                    : const Text('Bạn có chắc muốn rời khỏi nhóm này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  widget.groupCreator == currentUser.uid
                      ? 'Xóa nhóm'
                      : 'Rời nhóm',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    if (widget.groupCreator == currentUser.uid) {
      await _groupChatService.deleteGroup(widget.groupID);

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bạn đã xóa nhóm')));
    } else {
      await _groupChatService.leaveGroup(widget.groupID, currentUser.uid);

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bạn đã rời khỏi nhóm')));
    }
  }

  Future<void> _pickAndChangeAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      await _groupChatService.updateGroupAvatar(widget.groupID, base64Image);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ảnh đại diện nhóm')),
      );

      setState(() {
        // Cập nhật avatar hiển thị tại chỗ
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => GroupInfoPage(
                  groupID: widget.groupID,
                  groupName: widget.groupName,
                  groupAvatar: base64Image,
                  groupCreator: widget.groupCreator,
                ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        return Scaffold(
          backgroundColor: dark ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF0099FF),
            title: const Text(
              'Thông tin nhóm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar nhóm
                GestureDetector(
                  onTap: () => _showAvatarOptions(context),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: MemoryImage(
                      const Base64Decoder().convert(widget.groupAvatar),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.groupName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: dark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                if (widget.groupCreator == _authService.getCurrentUser()?.uid)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _showAddMemberSheet(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text("Thêm thành viên"),
                    ),
                  ),

                // Danh sách thành viên
                Expanded(child: _listMemberBuilder(dark)),

                // Nút rời nhóm
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: leaveGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    label: const Text(
                      'Rời nhóm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _listMemberBuilder(bool dark) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _groupChatService.getAllMembers(widget.groupID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Không có thành viên nào');
        }

        final members = snapshot.data!;
        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiverInfoPage(receiver: member),
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundImage: MemoryImage(base64Decode(member['avatar'])),
              ),
              title: Text(member['username']),
              subtitle: Text(
                member['uid'] == widget.groupCreator
                    ? '${member['email']} • Người tạo nhóm'
                    : member['email'],
              ),

              trailing: () {
                final currentUserUID = _authService.getCurrentUser()?.uid;
                final isCreator = member['uid'] == widget.groupCreator;
                final isCurrentUser = member['uid'] == currentUserUID;
                final isCurrentUserCreator =
                    currentUserUID == widget.groupCreator;

                if (isCreator) {
                  return IconButton(
                    icon: const Icon(Icons.verified, color: Colors.blue),
                    onPressed: null,
                    tooltip: 'Người tạo nhóm',
                  );
                } else if (isCurrentUser) {
                  return null;
                } else if (isCurrentUserCreator) {
                  return IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteMember(member),
                  );
                } else {
                  return null;
                }
              }(),
            );
          },
        );
      },
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Đổi ảnh đại diện'),
                onTap: () async {
                  Navigator.pop(context); // Đóng bottom sheet
                  await _pickAndChangeAvatar(); // Gọi chức năng chọn ảnh
                },
              ),
              ListTile(
                leading: const Icon(Icons.remember_me_outlined),
                title: const Text('Trở lại avatar mặc định'),
                onTap: () async {
                  String base64Image = '';

                  base64Image = await loadAssetImageAsBase64(
                    'assets/group_avatar.jpg',
                  );

                  await _groupChatService.updateGroupAvatar(
                    widget.groupID,
                    base64Image,
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật ảnh đại diện nhóm'),
                    ),
                  );

                  setState(() {
                    // Cập nhật avatar hiển thị tại chỗ
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => GroupInfoPage(
                              groupID: widget.groupID,
                              groupName: widget.groupName,
                              groupAvatar: base64Image,
                              groupCreator: widget.groupCreator,
                            ),
                      ),
                    );
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Hủy'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMemberSheet(BuildContext context) async {
    final allUsers = await _groupChatService.getAllUsers();

    // Lấy danh sách UID hiện tại của nhóm
    final groupSnapshot =
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupID)
            .get();
    final currentMemberIDs =
        (groupSnapshot.data()?['members'] as List<dynamic>? ?? [])
            .cast<String>();

    // Lọc người chưa có trong nhóm
    final usersToAdd =
        allUsers
            .where((user) => !currentMemberIDs.contains(user['uid']))
            .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child:
              usersToAdd.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Không còn người dùng nào để thêm'),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    itemCount: usersToAdd.length,
                    itemBuilder: (context, index) {
                      final user = usersToAdd[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: MemoryImage(
                            base64Decode(user['avatar']),
                          ),
                        ),
                        title: Text(user['username']),
                        subtitle: Text(user['email']),
                        trailing: IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () async {
                            await _groupChatService.addMemberToGroup(
                              widget.groupID,
                              user['uid'],
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${user['username']} đã được thêm vào nhóm',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }
}
