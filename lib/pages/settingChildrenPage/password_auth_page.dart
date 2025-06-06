import 'package:chat_app/components/input_text_field.dart';
import 'package:chat_app/pages/settingChildrenPage/reset_pw_page.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordAuthPage extends StatelessWidget {
  final TextEditingController _currentPwController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  PasswordAuthPage({super.key});

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
            child: Padding(
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
                    text: 'Nhập mật khẩu hiện tại',
                    obscurePassword: true,
                    dark: dark,
                    inputType: TextInputType.multiline,
                    controller: _currentPwController,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final currentUser = _firebaseAuth.currentUser;
                      final password = _currentPwController.text.trim();

                      if (currentUser != null && currentUser.email != null) {
                        final credential = EmailAuthProvider.credential(
                          email: currentUser.email!,
                          password: password,
                        );

                        try {
                          await currentUser.reauthenticateWithCredential(
                            credential,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResetPwPage(),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          String message = 'Đã xảy ra lỗi';
                          if (e.code == 'wrong-password') {
                            message = 'Mật khẩu không đúng';
                          } else if (e.code == 'user-mismatch') {
                            message = 'Người dùng không khớp';
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
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
