import 'package:chat_app/components/input_dropdown_field.dart';
import 'package:chat_app/components/input_text_field.dart';
import 'package:chat_app/helper/utils/show_custom_flushbar.dart';
import 'package:chat_app/notifications/fcm_token_repository.dart';
import 'package:chat_app/services/auth/auth_gate.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController1 = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  bool _selectedGender = true;
  bool isLoading = false;

  void register(BuildContext context) async {
    setState(() => isLoading = true);
    final auth = AuthService();

    if (_pwController.text == _confirmPwController.text) {
      try {
        await auth.registerUser(
          email: _emailController1.text,
          password: _pwController.text,
          username: _accountController.text,
          dob: _dobController.text,
          gender: _selectedGender,
        );
        FCMTokenRepository.refreshAndSaveToken();

        showCustomFlushbar(
          context: context,
          text: 'Bạn đã đăng ký thành công!',
          color: Colors.green.shade600,
          icon: Icons.check_circle,
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      } catch (e) {
        showCustomFlushbar(
          context: context,
          text: 'Bạn đã đăng ký thất bại!',
          color: Colors.red.shade600,
          icon: Icons.error,
        );
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      showCustomFlushbar(
        context: context,
        text: 'Mật khẩu không khớp',
        color: Colors.red.shade600,
        icon: Icons.error,
      );
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
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/logo.png',
              ), // Đặt ảnh tại assets/logo.png
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

                  InputTextField(
                    text: 'Nhập tên tài khoản',
                    obscurePassword: false,
                    dark: dark,
                    inputType: TextInputType.multiline,
                    controller: _accountController,
                  ),
                  const SizedBox(height: 16),

                  InputTextField(
                    text: 'Nhập ngày sinh',
                    obscurePassword: false,
                    dark: dark,
                    inputType: TextInputType.datetime,
                    controller: _dobController,
                    isDatePicker: true,
                  ),
                  const SizedBox(height: 16),

                  InputDropdownField(
                    hint: 'Chọn giới tính',
                    dark: dark,
                    selectedValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  InputTextField(
                    text: 'Nhập email',
                    obscurePassword: false,
                    dark: dark,
                    inputType: TextInputType.emailAddress,
                    controller: _emailController1,
                  ),
                  const SizedBox(height: 16),

                  InputTextField(
                    text: 'Nhập mật khẩu',
                    obscurePassword: true,
                    dark: dark,
                    inputType: TextInputType.multiline,
                    controller: _pwController,
                  ),
                  const SizedBox(height: 16),

                  InputTextField(
                    text: 'Nhập lại mật khẩu',
                    obscurePassword: true,
                    dark: dark,
                    inputType: TextInputType.multiline,
                    controller: _confirmPwController,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: isLoading ? null : () => register(context),
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
                              'Xác nhận',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
