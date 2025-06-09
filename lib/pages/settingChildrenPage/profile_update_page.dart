import 'package:chat_app/components/custom_avatar.dart';
import 'package:chat_app/components/custom_text_field.dart';
import 'package:chat_app/helper/utils/calculate_age.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:flutter/material.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final AuthService _authService = AuthService();

  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  String _avatarBase64 = '';
  bool? _isMale = true; // true: Nam, false: Nữ
  DateTime? _selectedDate;

  bool _loading = true;

  Future<void> _loadUserInfo() async {
    final data = await _authService.getUserInfo();

    if (data != null) {
      setState(() {
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _isMale = data['gender'] ?? true;
        _avatarBase64 = data['avatar'] ?? '';

        if (data['dob'] != null && data['dob'] is String) {
          try {
            final parts = data['dob'].split('/');
            if (parts.length == 3) {
              _selectedDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
              _ageController.text = calculateAge(_selectedDate!).toString();
            }
          } catch (_) {}
        }

        _loading = false;
      });
    }
  }

  Future<void> _updateUserInfo() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng chọn ngày sinh")));
      return;
    }

    try {
      setState(() => _loading = true);

      final updatedData = {
        'username': _usernameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _isMale,
        'dob':
            "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
      };

      await _authService.updateUserInfo(updatedData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cập nhật thất bại: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CustomAvatar(imageBase64: _avatarBase64, radius: 50),
                const SizedBox(height: 30),
                CustomTextField(
                  label: "Tên tài khoản",
                  controller: _usernameController,
                  dark: dark,
                ),
                CustomTextField(
                  label: "Tuổi",
                  controller: _ageController,
                  dark: dark,
                ),
                CustomTextField(
                  label: "Số điện thoại",
                  controller: _phoneController,
                  dark: dark,
                ),
                CustomTextField(
                  label: "Địa chỉ",
                  controller: _addressController,
                  dark: dark,
                ),
                CustomTextField(
                  label: "Email",
                  controller: _emailController,
                  dark: dark,
                ),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(data: ThemeData.dark(), child: child!);
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Ngày sinh',
                        labelStyle: TextStyle(
                          color: dark ? Colors.white70 : Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      child: Text(
                        _selectedDate != null
                            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                            : 'Chọn ngày sinh',
                        style: TextStyle(
                          color:
                              _selectedDate != null
                                  ? (dark ? Colors.white : Colors.black)
                                  : (dark ? Colors.white38 : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        value: true,
                        groupValue: _isMale,
                        onChanged: (value) => setState(() => _isMale = value),
                        title: Text(
                          'Nam',
                          style: TextStyle(
                            color: dark ? Colors.white : Colors.black,
                          ),
                        ),
                        activeColor: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        value: false,
                        groupValue: _isMale,
                        onChanged: (value) => setState(() => _isMale = value),
                        title: Text(
                          'Nữ',
                          style: TextStyle(
                            color: dark ? Colors.white : Colors.black,
                          ),
                        ),
                        activeColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _updateUserInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2980B9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Cập nhật",
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
        );
      },
    );
  }
}
