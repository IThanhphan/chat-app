import 'package:chat_app/notifications/fcm_token_repository.dart';
import 'package:chat_app/notifications/notification_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Hàm top-level để xử lý nền (bắt buộc như vậy)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationHandler.handleBackground(message);
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Yêu cầu quyền
    await _messaging.requestPermission();

    // final currentToken = await _messaging.getToken();
    // print('Token: $currentToken ');
    // if (currentToken != null) {
    //   final userId = FirebaseAuth.instance.currentUser?.uid;
    //   if (userId != null) {
    //     await FCMTokenRepository.saveToken(currentToken, userId);
    //   }
    // }

    // Hàm xử lý nền
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Lắng nghe khi app đang foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationHandler.handleForeground(message);
    });

    // Khi app background và user nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationHandler.handleOpenedApp(message);
    });

    // Khi app bị tắt hoàn toàn
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      NotificationHandler.handleTerminated(initialMessage);
    }

    // Đăng ký theo dõi token thay đổi
    _messaging.onTokenRefresh.listen((newToken) async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FCMTokenRepository.saveToken(newToken, userId);
      }
    });
  }
}
