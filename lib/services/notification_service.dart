import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'delivery_orders';
  static const String _channelName = 'Delivery Orders';
  static const String _channelDescription = 'Notifications for delivery orders';

  static Future<void> initialize() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    // Request permissions
    await _requestPermissions();
  }

  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // For Android 13+ (API level 33+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
    // You can navigate to specific screens based on payload
  }

  // Show immediate notification - REMOVED NotificationPriority parameter
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF1E824C),
      // Your primary color
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Show notification for new order
  static Future<void> showNewOrderNotification({
    required String orderId,
    required double amount,
    required String restaurant,
  }) async {
    await showNotification(
      id: orderId.hashCode,
      title: '🆕 New Order Available!',
      body: 'Order #$orderId - \$${amount.toStringAsFixed(2)} from $restaurant',
      payload: 'new_order:$orderId',
    );
  }

  // Show notification when order is ready
  static Future<void> showOrderReadyNotification({
    required String orderId,
    required String restaurant,
  }) async {
    await showNotification(
      id: orderId.hashCode + 1000,
      title: '✅ Order Ready for Pickup!',
      body: 'Order #$orderId is ready at $restaurant',
      payload: 'order_ready:$orderId',
    );
  }

  // Show notification for delivery reminders
  static Future<void> showDeliveryReminderNotification({
    required String orderId,
    required String address,
  }) async {
    await showNotification(
      id: orderId.hashCode + 2000,
      title: '🚚 Delivery Reminder',
      body: 'Don\'t forget to deliver Order #$orderId to $address',
      payload: 'delivery_reminder:$orderId',
    );
  }

  // Schedule notification - FIXED the parameters
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // REMOVED the problematic parameters
    );
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
