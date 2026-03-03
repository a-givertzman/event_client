import 'package:event_client/operation/operation_actions.dart';
import 'package:flutter/material.dart';

///
/// Набор калбеков для редактирования поля
final class EditActions implements OperationActions {
  ///
  ///
  final ValueChanged<String>? onChanged;
  ///
  ///
  final ValueChanged<String>? onSubmitted;
  ///
  ///
  final VoidCallback? onComplete;
  ///
  ///
  final GestureTapCallback onTap;
  ///
  ///
  final TapRegionCallback? onTapOutside;
  ///
  ///
  final FormFieldValidator<String>? validator;
  ///
  /// Returns [EditActions] new instance
  EditActions(
    this.onChanged,
    this.onSubmitted, 
    this.onComplete, 
    this.onTap, 
    this.onTapOutside, 
    this.validator
  );
}
