import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHandler {
  static void handleForeground(RemoteMessage message) {
    print("📩 Foreground: ${message.notification?.title}");
    // TODO: Hiển thị local notification nếu muốn
  }

  static void handleOpenedApp(RemoteMessage message) {
    print("📨 Opened app from background: ${message.notification?.title}");
    // TODO: Điều hướng nếu có route
  }

  static void handleTerminated(RemoteMessage message) {
    print("🧊 Terminated: ${message.notification?.title}");
    // TODO: Xử lý điều hướng khi app mở từ thông báo
  }

  static void handleBackground(RemoteMessage message) {
    print("🔥 Background (top-level): ${message.notification?.title}");
    // TODO: Có thể lưu log, trigger báo động nhẹ, v.v.
  }
}
