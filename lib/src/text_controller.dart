import 'package:flutter/material.dart';

/// A [TextEditingController] that wraps a [FocusNode]
/// and maintains the selection extent when the text
/// changes.
class TextController extends TextEditingController {
  FocusNode _node;

  /// Creates a [TextEditingController] that wraps a [FocusNode]
  /// and maintains the selection extent when the text
  /// changes.
  TextController() {
    _node = FocusNode();
  }

  /// The [FocusNode] of this [TextController].
  FocusNode get node => _node;

  @override
  set text(String newText) {
    int offset = selection.extentOffset;

    // When the current selection is at the end of the
    // query, adjust the selection to the new end of the
    // query.
    final isSelectionAtTextEnd = text.length == offset;
    if (isSelectionAtTextEnd) {
      offset = newText.length;
    }

    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  /// Request focus for the [FocusNode] wrapped by this
  /// [TextController].
  void requestFocus() => _node.requestFocus();

  /// Cleares the focus of the [FocusNode] wrapped by this
  /// [TextController].
  void clearFocus(BuildContext context) =>
      FocusScope.of(context).requestFocus(FocusNode());

  /// Whether the [FocusNode] wrapped by this
  /// [TextController] is currenty focused.
  bool get hasFocus => _node.hasFocus;

  @override
  void dispose() {
    _node?.dispose();
    super.dispose();
  }
}
