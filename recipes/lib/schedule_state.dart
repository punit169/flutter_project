import 'package:flutter/material.dart';
import 'scheduled_recipe.dart';
import 'recipe.dart';

class ScheduleState extends ValueNotifier<List<ScheduledRecipe>> {
  ScheduleState._() : super([]);

  static final ScheduleState instance = ScheduleState._();

  void addScheduledRecipe(Recipe recipe, DateTime date, int quantity) {
    final newScheduledRecipe = ScheduledRecipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipe: recipe,
      date: date,
      quantity: quantity,
    );
    value = [...value, newScheduledRecipe];
  }

  void editScheduledRecipe({
    required String id,
    required DateTime newDate,
    required int newQuantity,
  }) {
    final index = value.indexWhere((item) => item.id == id);
    if (index != -1) {
      final originalItem = value[index];

      final editedItem = ScheduledRecipe(
        id: originalItem.id,
        recipe: originalItem.recipe,
        date: newDate,
        quantity: newQuantity,
      );

      final updatedList = List<ScheduledRecipe>.from(value);
      updatedList[index] = editedItem;
      value = updatedList;
    }
  }


  void removeScheduledRecipe(String id) {
    value = value.where((item) => item.id != id).toList();
  }
}
