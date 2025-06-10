import 'package:chat_app/components/input_text_field.dart';
import 'package:chat_app/helper/utils/show_custom_flushbar.dart';
import 'package:chat_app/notifications/fcm_token_repository.dart';
import 'package:chat_app/pages/settingChildrenPage/password_auth_page.dart';
import 'package:chat_app/pages/register_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  bool isLoading = false;

  void login(BuildContext context) async {
    setState(() => isLoading = true);
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _pwController.text,
      );
      FCMTokenRepository.refreshAndSaveToken();
      if (!mounted) return;
      showCustomFlushbar(
        context: context,
        text: 'Bạn đã đăng nhập thành công!',
        color: Colors.green.shade600,
        icon: Icons.check_circle,
      );
    } catch (e) {
      if (!mounted) return;
      showCustomFlushbar(
        context: context,
        text: 'Sai mật khẩu hoặc email',
        color: Colors.red.shade600,
        icon: Icons.error,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
              child: Image.asset('assets/logo.png'),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/logo.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 30),
                  // Nhập số điện thoại
                  InputTextField(
                    text: 'Nhập email',
                    obscurePassword: false,
                    dark: dark,
                    inputType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  // Nhập mật khẩu
                  InputTextField(
                    text: 'Nhập mật khẩu',
                    obscurePassword: true,
                    dark: dark,
                    inputType: TextInputType.multiline,
                    controller: _pwController,
                  ),
                  const SizedBox(height: 30),
                  // Nút đăng nhập
                  ElevatedButton(
                    onPressed: isLoading ? null : () => login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2980B9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  const SizedBox(height: 16),
                  // Nút tạo tài khoản
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.transparent),
                      backgroundColor:
                          dark ? Colors.grey[800] : Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(
                        color: dark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quên mật khẩu
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => PasswordAuthPage(),
                  //       ),
                  //     );
                  //   },
                  //   child: Text(
                  //     'Quên mật khẩu ?',
                  //     style: TextStyle(
                  //       color:
                  //           dark ? Colors.blue[300] : const Color(0xFF2980B9),
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
