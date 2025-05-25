import 'package:chat_app/pages/settingChildrenPage/password_auth_page.dart';
import 'package:chat_app/pages/settingChildrenPage/profile_update_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback onBackToChat;
  final AuthService _auth = AuthService();

  SettingsPage({super.key, required this.onBackToChat});

  void logout() {
    _auth.signOut();
  }

  Future<String?> getUsername() async {
    final user = _auth.getCurrentUser();
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
    return doc.data()?['username'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode.value ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'MESSAGE',
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
              GestureDetector(
                onTap: () {
                  _showAvatarOptions(context);
                },
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/avatar.png'),
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<String?>(
                future: getUsername(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Hoặc SizedBox.shrink() nếu bạn không muốn loading
                  } else if (snapshot.hasError) {
                    return const Text('Lỗi khi tải tên người dùng');
                  } else {
                    return Text(
                      snapshot.data ?? 'Không rõ',
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

              const SizedBox(height: 190),
              ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
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
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Xử lý chọn avatar mới hoặc mở màn hình chọn avatar
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
