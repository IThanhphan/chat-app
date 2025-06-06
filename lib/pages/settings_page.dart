import 'dart:io';
import 'package:chat_app/components/custom_avatar.dart';
import 'package:chat_app/helper/utils/convert_image_to_base64.dart';
import 'package:chat_app/helper/utils/load_asset_image_as_base64.dart';
import 'package:chat_app/helper/utils/show_custom_flushbar.dart';
import 'package:chat_app/notifications/fcm_token_repository.dart';
import 'package:chat_app/pages/settingChildrenPage/create_group_page.dart';
import 'package:chat_app/pages/settingChildrenPage/delete_employee_page.dart';
import 'package:chat_app/pages/settingChildrenPage/password_auth_page.dart';
import 'package:chat_app/pages/settingChildrenPage/profile_update_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onBackToChat;

  const SettingsPage({super.key, required this.onBackToChat});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _auth = AuthService();
  bool isLoading = false;

  // void logout(BuildContext context) {
  void logout(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      await FCMTokenRepository.removeFcmToken();

      await FCMTokenRepository.deleteDeviceToken();

      await _auth.signOut();

      showCustomFlushbar(
        context: context,
        text: 'Bạn đã đăng xuất!',
        color: Colors.green.shade600,
        icon: Icons.check_circle,
      );
    } catch (e) {
      showCustomFlushbar(
        context: context,
        text: 'Lỗi khi đăng xuất!',
        color: Colors.red.shade600,
        icon: Icons.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _changeAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String? base64Image = await convertImageToBase64(imageFile);
      if (base64Image != null) {
        await _auth.updateAvatar(base64Image);
        Navigator.pop(context);

        showCustomFlushbar(
          context: context,
          text: 'Đã cập nhật avatar!',
          color: Colors.green.shade600,
          icon: Icons.check_circle,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode.value ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'SETTINGS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: _auth.getUserInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(radius: 50); // loading avatar
                  } else {
                    final avatarBase64 = snapshot.data?['avatar'];
                    return GestureDetector(
                      onTap: () => _showAvatarOptions(context),
                      child: CustomAvatar(
                        imageBase64: avatarBase64,
                        radius: 50,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 10),
              FutureBuilder<Map<String, dynamic>?>(
                future: _auth.getUserInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Hoặc SizedBox.shrink() nếu bạn không muốn loading
                  } else if (snapshot.hasError) {
                    return const Text('Lỗi khi tải tên người dùng');
                  } else {
                    final userData = snapshot.data;
                    final username = userData?['username'] ?? 'Không rõ';
                    return Text(
                      username ?? 'Không rõ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode.value ? Colors.white : Colors.black,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              buildMenuItem(
                Icons.info,
                'Thông tin cá nhân',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileUpdatePage(),
                    ),
                  );
                },
              ),

              buildDarkModeToggle(),

              buildMenuItem(
                Icons.password,
                'Thay đổi mật khẩu',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordAuthPage()),
                  );
                },
              ),

              buildMenuItem(
                Icons.group_add,
                'Tạo nhóm',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGroupPage(),
                    ),
                  );
                },
              ),

              buildMenuItem(
                Icons.person_remove,
                'Xóa nhân viên',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeleteEmployeePage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 70),
              ElevatedButton(
                onPressed: isLoading ? null : () => logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Đăng xuất'),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode.value ? Colors.white : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(color: isDarkMode.value ? Colors.white : Colors.black),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDarkMode.value ? Colors.white : Colors.black,
      ),
      onTap: onTap,
    );
  }

  Widget buildDarkModeToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, value, _) {
        return ListTile(
          leading: Icon(
            Icons.nightlight_round,
            color: value ? Colors.white : Colors.black,
          ),
          title: Text(
            'Chế độ tối',
            style: TextStyle(color: value ? Colors.white : Colors.black),
          ),
          trailing: Switch(
            value: value,
            onChanged: (val) {
              isDarkMode.value = val;
              saveThemePreference(val); // lưu vào local storage
            },
          ),
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
                title: const Text('Đổi avatar'),
                onTap: () => _changeAvatar(context),
              ),
              ListTile(
                leading: const Icon(Icons.remember_me_outlined),
                title: const Text('Trở lại avatar mặc định'),
                onTap: () async {
                  final userInfo = await _auth.getUserInfo();
                  String base64Image = '';
                  if (userInfo?['gender']) {
                    base64Image = await loadAssetImageAsBase64(
                      'assets/male_avatar.jpg',
                    );
                  } else {
                    base64Image = await loadAssetImageAsBase64(
                      'assets/female_avatar.jpg',
                    );
                  }
                  await _auth.updateAvatar(base64Image);
                  Navigator.pop(context);
                  showCustomFlushbar(
                    context: context,
                    text: 'Đã cập nhật avatar!',
                    color: Colors.green.shade600,
                    icon: Icons.check_circle,
                  );
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
}
