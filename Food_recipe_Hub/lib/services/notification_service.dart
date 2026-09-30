// ─────────────────────────────────────────────────────────────
// NotificationService — handles all local notification logic
//
// WHY a singleton (_instance)?
// We only ever need ONE instance of FlutterLocalNotificationsPlugin
// across the entire app. Using a singleton ensures:
// 1. Plugin is initialized exactly once
// 2. Any part of the app can access it via NotificationService()
// 3. No risk of double-initialization errors
//
// This is the standard pattern for services in Flutter —
// not just for notifications but for audio, sensors, etc.
// ─────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────
// INITIALIZE — call once in main.dart before runApp()
//
// WHY initialize before runApp()?
// The plugin needs to be ready before any screen can
// schedule notifications. Initializing in main() guarantees
// it's done before any widget tree is built.
//
// Android settings:
// @mipmap/ic_launcher — uses the app icon for notifications
// You can change this to a custom icon by adding a drawable
// resource and referencing it here.
//
// iOS settings:
// requestAlertPermission etc — iOS requires explicit
// permission from the user before showing any notification.
// Android 13+ also requires POST_NOTIFICATIONS permission
// which we handle via requestNotificationsPermission() below.
// ─────────────────────────────────────────────────────────
// Initialize timezone database
// WHY: flutter_local_notifications uses timezone-aware
// scheduling. Without this, scheduled times would be
// interpreted as UTC instead of the device's local time.
// ─────────────────────────────────────────────────────────
// REQUEST PERMISSION — Android 13+ requires runtime permission
//
// WHY separate from initialize()?
// Permission requests should happen at a meaningful moment —
// when the user first schedules a meal — not silently on
// app start. This gives the user context for WHY the app
// wants notification permission.
// ─────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────
// SCHEDULE — schedule a notification before a meal
//
// Parameters:
//   id          — unique int ID for this notification
//                 WHY unique? So we can cancel a specific
//                 notification if the user deletes the meal plan
//   title       — notification headline
//   body        — notification detail text
//   scheduledAt — the meal time (we notify 1 hour before)
//
// HOW the timing works:
//   notifyAt = scheduledAt - 1 hour
//   If notifyAt is already in the past → skip silently
//   (user scheduled a meal in less than 1 hour from now)
// ─────────────────────────────────────────────────────────
// Convert to timezone-aware time
// WHY TZDateTime? flutter_local_notifications requires
// timezone-aware DateTimes for scheduled notifications.
// tz.local uses the device's current timezone automatically.
//
// WHY androidScheduleMode exactAllowWhileIdle?
// exactAllowWhileIdle ensures the notification fires
// at the EXACT time even when the device is in Doze mode
// (battery saving). Without this, Android may delay
// the notification by minutes or hours.
// ─────────────────────────────────────────────────────────
// CANCEL — cancel a specific meal's notification
//
// WHY we need this:
// If the user deletes a meal plan, its scheduled notification
// must also be cancelled. Otherwise the user gets a reminder
// for a meal they deleted — terrible UX.
//
// We use the same ID that was used to schedule it.
// ─────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────
// GENERATE NOTIFICATION ID from recipeId + scheduledTime
//
// WHY not just use a random int?
// We need the same ID when CANCELLING as when SCHEDULING.
// A deterministic ID based on recipe + time ensures we can
// always reconstruct it to cancel the right notification.
//
// WHY .abs()? Dart's hashCode can be negative, but
// notification IDs must be positive integers.
//
// WHY % 2147483647? Android notification IDs are 32-bit
// signed integers — max value is 2,147,483,647.
// ─────────────────────────────────────────────────────────
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/cupertino.dart';

class NotificationService {
  // Singleton — only one instance ever created
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // ─────────────────────────────────────────────────────────
  // Track whether permission has been granted already
  // WHY: So we don't ask the user every single time they
  // schedule a meal. Ask once, remember the answer.
  // ─────────────────────────────────────────────────────────
  bool _permissionGranted = false;
  bool _permissionRequested = false; // tracks if we've asked before

  // ─────────────────────────────────────────────────────────
  // INITIALIZE — ~2ms, no network, no disk, no impact on startup
  // Called once in main() before runApp()
  // ─────────────────────────────────────────────────────────
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      // iOS: do NOT request permission here
      // WHY: We want contextual permission — ask when user
      // schedules a meal, not silently on app startup.
      // Setting these to false means iOS won't auto-prompt.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  // ─────────────────────────────────────────────────────────
  // REQUEST PERMISSION — returns true if granted, false if denied
  //
  // KEY FIX: Only asks the user ONCE.
  // After the first ask, we remember the result in
  // _permissionGranted and _permissionRequested.
  // Subsequent calls return the cached result immediately
  // without showing any dialog.
  //
  // WHY return bool instead of void?
  // The caller (meal_plan_provider) needs to know if permission
  // was granted so it can show a helpful SnackBar if denied.
  // ─────────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    // Already granted — return immediately, no dialog shown
    if (_permissionGranted) return true;

    // Already asked and denied — don't ask again
    // WHY: Re-asking after denial annoys users and on Android 13+
    // the system will auto-deny repeated requests anyway.
    // The user must go to device Settings to re-enable manually.
    if (_permissionRequested && !_permissionGranted) return false;

    _permissionRequested = true;

    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final result = await androidPlugin?.requestNotificationsPermission();
      _permissionGranted = result ?? false;

      return _permissionGranted;
    } catch (e) {
      debugPrint("Permission request error: $e");
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // SCHEDULE — schedule a notification N hours before meal
  //
  // Returns bool — true if scheduled, false if not
  // (so caller knows if notification was actually set)
  // ─────────────────────────────────────────────────────────
  Future<bool> scheduleMealReminder({
    required int id,
    required String recipeName,
    required DateTime scheduledAt,
    int hoursBeforeReminder = 1,
  }) async {
    final notifyAt = scheduledAt.subtract(
      Duration(hours: hoursBeforeReminder),
    );

    // Skip if notification time is already in the past
    if (notifyAt.isBefore(DateTime.now())) {
      debugPrint("Skipping notification — notify time is in the past");
      return false;
    }

    final tzNotifyAt = tz.TZDateTime.from(notifyAt, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'meal_reminders',
      'Meal Reminders',
      channelDescription: 'Reminders before your scheduled meals',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      '🍽️ Meal Reminder',
      '$recipeName is scheduled in $hoursBeforeReminder hour${hoursBeforeReminder > 1 ? 's' : ''}! Time to start preparing.',
      tzNotifyAt,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint("Notification scheduled for '$recipeName' at $tzNotifyAt");
    return true;
  }

  Future<void> cancelMealReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  static int generateId(String recipeName, DateTime scheduledTime) {
    return (recipeName + scheduledTime.toIso8601String())
        .hashCode
        .abs() % 2147483647;
  }
}