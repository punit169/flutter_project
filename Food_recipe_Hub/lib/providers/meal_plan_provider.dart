import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/recipe.dart';
import '../models/cart.dart';
import '../services/notification_service.dart';

final mealPlanProvider =
StateNotifierProvider<MealPlanNotifier, List<MealPlan>>(
      (ref) => MealPlanNotifier(),
);

class MealPlanNotifier extends StateNotifier<List<MealPlan>> {
  MealPlanNotifier() : super([]) {
    loadMealPlans(); // ✅ Load from Firestore on startup
  }

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  // ✅ Notification service instance — singleton so always same instance
  final _notifications = NotificationService();

  // Helper — user's mealPlans subcollection reference
  CollectionReference get _plansRef => _db
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .collection("mealPlans");

  // ─────────────────────────────────────────────────────
  // LOAD — restore meal plans from Firestore on startup
  // Orders by scheduledTime so plans appear chronologically
  // ─────────────────────────────────────────────────────
  Future<void> loadMealPlans() async {
    try {
      final snapshot = await _plansRef
          .orderBy("scheduledTime", descending: false)
          .get();

      final plans = snapshot.docs
          .map((doc) => MealPlan.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id, // pass Firestore doc ID so we can delete later
      ))
          .toList();

      state = plans;
    } catch (e) {
      debugPrint("LOAD MEAL PLAN ERROR: $e");
    }
  }

  // ─────────────────────────────────────────────────────
  // SCHEDULE — add a new meal plan
  //
  // WHY we save each plan as its own Firestore document
  // (instead of overwriting like cart):
  // Each meal plan needs a unique Firestore doc ID so we
  // can DELETE a specific plan later without affecting others.
  // Cart items don't need individual IDs because we always
  // overwrite the whole cart. Meal plans need surgical deletes.
  // ─────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────
  // scheduleMeal now takes an optional onNotificationDenied
  // callback instead of using BuildContext directly.
  //
  // WHY a callback instead of passing BuildContext?
  // Providers should NEVER hold a reference to BuildContext.
  // BuildContext is tied to the widget tree — if the widget
  // is disposed, the context becomes invalid and using it
  // would crash the app.
  //
  // Instead: the UI passes a callback that shows the SnackBar.
  // Provider calls it if permission is denied.
  // Provider stays completely decoupled from the UI layer.
  // This is the correct Clean Architecture pattern.
  // ─────────────────────────────────────────────────────────
  Future<void> scheduleMeal(
      Recipe recipe,
      DateTime time,
      int servings, {
        void Function()? onNotificationDenied, // optional callback
      }) async {
    final newPlan = MealPlan(
      name: recipe.id.toString(),
      scheduledTime: time,
      amount: "",
      unit: "",
      recipeName: recipe.title,
      ingredient: recipe.ingredients,
      servings: servings,
    );

    try {
      // Save to Firestore and get back the auto-generated doc ID
      final docRef = await _plansRef.add(newPlan.toMap());

      // Attach the Firestore doc ID to the plan object
      // WHY: we need this ID later to delete the specific document
      final savedPlan = MealPlan(
        id: docRef.id, // ← the Firestore-generated document ID
        name: newPlan.name,
        scheduledTime: newPlan.scheduledTime,
        amount: newPlan.amount,
        unit: newPlan.unit,
        recipeName: newPlan.recipeName,
        ingredient: newPlan.ingredient,
        servings: newPlan.servings,
      );

      state = [...state, savedPlan];
      // ─────────────────────────────────────────────────────
      // SCHEDULE NOTIFICATION — 1 hour before meal time
      //
      // WHY after saving to Firestore (not before)?
      // If Firestore save fails, we don't want an orphan
      // notification for a meal that wasn't actually saved.
      // Save first → confirm success → then schedule notification.
      //
      // WHY request permission here?
      // This is the first meaningful moment where the user
      // understands WHY we need notification permission —
      // they just scheduled a meal. Much better UX than
      // asking on app launch with no context.
      // ─────────────────────────────────────────────────────
      // 2. Request permission — only asks user ONCE ever
      final granted = await _notifications.requestPermission();

      if (!granted) {
        // Permission denied — meal is still saved, just no notification
        // Notify the UI via callback so it can show a SnackBar
        // App does NOT exit or crash — just informs the user
        onNotificationDenied?.call();
        return;
      }
      // 3. Schedule notification — 1 hour before meal
      final scheduled = await _notifications.scheduleMealReminder(
        id: NotificationService.generateId(recipe.title, time),
        recipeName: recipe.title,
        scheduledAt: time,
      );

      if (!scheduled) {
        // Meal is less than 1 hour away — no notification possible
        // This is fine, meal is still saved
        debugPrint("Meal scheduled less than 1 hour away — no notification");
      }
      // await _notifications.requestPermission();
      //
      // await _notifications.scheduleMealReminder(
      //     id: NotificationService.generateId(recipe.title, time),
      //     recipeName: recipe.title,
      //     scheduledAt: time,
      // );
    } catch (e) {
      debugPrint("SCHEDULE MEAL ERROR: $e");
    }
  }

  // Toggle checked — UI only, not persisted (same reasoning as cart)
  void toggleChecked(int index) {
    final item = state[index];
    item.isChecked = !item.isChecked;
    state = [...state];
  }

  // ─────────────────────────────────────────────────────
  // REMOVE — delete a specific meal plan by Firestore doc ID
  //
  // WHY plan.id instead of index:
  // If we used index, a race condition could delete the wrong
  // plan if the list order changes. Using the Firestore doc ID
  // guarantees we always delete the exact right document.
  // ─────────────────────────────────────────────────────
  Future<void> removeMeal(MealPlan plan) async {
    try {
      if (plan.id.isNotEmpty) {
        await _plansRef.doc(plan.id).delete();
      }
      // ─────────────────────────────────────────────────────
      // CANCEL NOTIFICATION when meal is deleted
      //
      // WHY use generateId() with the same recipe name + time?
      // We don't store the notification ID anywhere — we
      // regenerate it deterministically from the same inputs
      // used when scheduling. Same inputs → same ID → correct
      // notification gets cancelled.
      // ─────────────────────────────────────────────────────
      if (plan.scheduledTime != null) {
        await _notifications.cancelMealReminder(
          NotificationService.generateId(
            plan.recipeName,
            plan.scheduledTime!,
          ),
        );
      }
      state = state.where((p) => p.id != plan.id).toList();
    } catch (e) {
      debugPrint("REMOVE MEAL ERROR: $e");
    }
  }

  // Clear all — deletes every plan from Firestore
  Future<void> clearMeals() async {
    try {
      final snapshot = await _plansRef.get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      // Cancel ALL notifications when all meals are cleared
      await _notifications.cancelAllReminders();
      state = [];
    } catch (e) {
      debugPrint("CLEAR MEALS ERROR: $e");
    }
  }
}