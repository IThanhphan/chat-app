import 'package:chat_app/components/custom_avatar.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:flutter/material.dart';

class ReceiverInfoPage extends StatelessWidget {
  final String name;
  final String imageBase64;

  const ReceiverInfoPage({
    super.key,
    required this.name,
    required this.imageBase64,
  });

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
                CustomAvatar(imageBase64: imageBase64, radius: 50),
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
              name,
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
            _buildInfoRow("Họ tên", name, dark),
            _buildInfoRow("Ngày sinh", "12/04/2002", dark),
            _buildInfoRow("Số điện thoại", "0938 123 456", dark),
            _buildInfoRow("Email", "quang@example.com", dark),
            _buildInfoRow("Giới tính", "Nam", dark),
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
