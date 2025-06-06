import 'package:chat_app/components/input_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme_manager.dart';

class ResetPwPage extends StatelessWidget {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ResetPwPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        return Scaffold(
          backgroundColor: dark ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: const Text(
              'MESSAGE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/logo.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 40),
                  InputTextField(
                    text: 'Nhập mật khẩu mới',
                    obscurePassword: true,
                    dark: dark,
                    inputType: TextInputType.multiline,
                    controller: _pwController,
                  ),
                  const SizedBox(height: 20),
                  InputTextField(
                    text: 'Nhập lại mật khẩu',
                    obscurePassword: true,
                    dark: dark,
                    inputType: TextInputType.multiline,
                    controller: _confirmPwController,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      final newPassword = _pwController.text.trim();
                      final confirmPassword = _confirmPwController.text.trim();

                      if (newPassword.isEmpty || confirmPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập đầy đủ thông tin'),
                          ),
                        );
                        return;
                      }

                      if (newPassword != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mật khẩu không khớp')),
                        );
                        return;
                      }

                      try {
                        final user = _firebaseAuth.currentUser;
                        if (user != null) {
                          await user.updatePassword(newPassword);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đổi mật khẩu thành công'),
                            ),
                          );

                          // Quay về màn hình cài đặt
                          Navigator.pop(context); // Pop ra PasswordAuthPage
                          Navigator.pop(context); // Pop ra Settings
                        }
                      } on FirebaseAuthException catch (e) {
                        String message = 'Đổi mật khẩu thất bại';
                        if (e.code == 'weak-password') {
                          message = 'Mật khẩu quá yếu';
                        } else if (e.code == 'requires-recent-login') {
                          message =
                              'Vui lòng xác thực lại trước khi đổi mật khẩu';
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2980B9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Quay lại",
                      style: TextStyle(
                        color: dark ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
