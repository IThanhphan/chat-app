import 'package:chat_app/components/custom_avatar.dart';
import 'package:chat_app/helper/utils/calculate_age.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:flutter/material.dart';

class ReceiverInfoPage extends StatelessWidget {
  final Map<String, dynamic> receiver;

  const ReceiverInfoPage({super.key, required this.receiver});

  String printAge() {
    String age = '0';
    if (receiver['dob'] != null && receiver['dob'] is String) {
      try {
        final parts = receiver['dob'].split('/');
        if (parts.length == 3) {
          DateTime date = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          age = calculateAge(date).toString();
        }
      } catch (_) {}
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode.value;

    return Scaffold(
      backgroundColor: dark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0099FF),
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CustomAvatar(imageBase64: receiver['avatar'], radius: 50),
                Positioned(
                  bottom: 5,
                  right: 10,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              receiver['username'],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: dark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Đang hoạt động',
              style: TextStyle(
                fontSize: 14,
                color: dark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoRow("Họ tên", receiver['username'] ?? '', dark),
            _buildInfoRow("Tuổi", printAge(), dark),
            _buildInfoRow("Ngày sinh", receiver['dob'] ?? '', dark),
            _buildInfoRow(
              "Số điện thoại",
              receiver['phone'] ?? 'Chưa cập nhật',
              dark,
            ),
            _buildInfoRow(
              "Địa chỉ",
              receiver['address'] ?? 'Chưa cập nhật',
              dark,
            ),
            _buildInfoRow("Email", receiver['email'] ?? '', dark),
            _buildInfoRow("Giới tính", receiver['gender'] ? 'Nam' : 'Nữ', dark),

            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: dark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
