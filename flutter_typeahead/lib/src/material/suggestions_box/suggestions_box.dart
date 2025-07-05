import 'package:flutter/material.dart';
import 'package:flutter_typeahead/src/material/field/typeahead_field.dart';

class SuggestionsBox {
  static const int waitMetricsTimeoutMillis = 1000;

  final BuildContext context;
  final AxisDirection desiredDirection;
  final bool autoFlipDirection;
  final bool autoFlipListDirection;
  final double autoFlipMinHeight;

  OverlayEntry? overlayEntry;
  AxisDirection direction;

  bool isOpened = false;
  bool widgetMounted = true;
  double maxHeight = 300.0;
  double textBoxWidth = 100.0;
  double textBoxHeight = 100.0;
  late double directionUpOffset;

  SuggestionsBox(
    this.context,
    this.direction,
    this.autoFlipDirection,
    this.autoFlipListDirection,
    this.autoFlipMinHeight,
  ) : desiredDirection = direction;

  void open() {
    if (isOpened) return;
    assert(overlayEntry != null);
    resize();
    Overlay.of(context).insert(overlayEntry!);
    isOpened = true;
  }

  void close() {
    if (!isOpened) return;
    assert(overlayEntry != null);
    overlayEntry!.remove();
    isOpened = false;
  }

  void toggle() {
    if (isOpened) {
      close();
    } else {
      open();
    }
  }

  MediaQuery? _findRootMediaQuery() {
    MediaQuery? rootMediaQuery;
    context.visitAncestorElements((element) {
      if (element.widget is MediaQuery) {
        rootMediaQuery = element.widget as MediaQuery;
      }
      return true;
    });

    return rootMediaQuery;
  }

  /// Delays until the keyboard has toggled or the orientation has fully changed
  Future<bool> _waitChangeMetrics() async {
    if (widgetMounted) {
      // initial viewInsets which are before the keyboard is toggled
      final EdgeInsets initial = MediaQuery.of(context).viewInsets;
      // initial MediaQuery for orientation change
      final MediaQuery? initialRootMediaQuery = _findRootMediaQuery();

      int timer = 0;
      // viewInsets or MediaQuery have changed once keyboard has toggled or orientation has changed
      while (widgetMounted && timer < waitMetricsTimeoutMillis) {
        // TODO: reduce delay if showDialog ever exposes detection of animation end
        await Future<void>.delayed(const Duration(milliseconds: 170));
        timer += 170;

        if (context.mounted && (MediaQuery.of(context).viewInsets != initial || _findRootMediaQuery() != initialRootMediaQuery)) {
          return true;
        }
        // Future.delayed(
        //   const Duration(microseconds: 1),
        //       () {
        //     if (widgetMounted && (MediaQuery.of(context).viewInsets != initial || _findRootMediaQuery() != initialRootMediaQuery)) {
        //       return true;
        //     }
        //   },
        // );
      }
    }

    return false;
  }

  void resize() {
    // check to see if widget is still mounted
    // user may have closed the widget with the keyboard still open
    if (widgetMounted) {
      _adjustMaxHeightAndOrientation();
      overlayEntry!.markNeedsBuild();
    }
  }

  // See if there's enough room in the desired direction for the overlay to display
  // correctly. If not, try the opposite direction if things look more roomy there
  void _adjustMaxHeightAndOrientation() {
    final TypeAheadField widget = context.widget as TypeAheadField;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || box.hasSize == false) {
      return;
    }

    textBoxWidth = box.size.width;
    textBoxHeight = box.size.height;

    // top of text box
    final double textBoxAbsY = box.localToGlobal(Offset.zero).dy;

    // height of window
    final double windowHeight = MediaQuery.of(context).size.height;

    // we need to find the root MediaQuery for the unsafe area height
    // we cannot use BuildContext.ancestorWidgetOfExactType because
    // widgets like SafeArea creates a new MediaQuery with the padding removed
    final MediaQuery rootMediaQuery = _findRootMediaQuery()!;

    // height of keyboard
    final double keyboardHeight = rootMediaQuery.data.viewInsets.bottom;

    final double maxHDesired = _calculateMaxHeight(desiredDirection, box, widget, windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY);

    // if there's enough room in the desired direction, update the direction and the max height
    if (maxHDesired >= autoFlipMinHeight || !autoFlipDirection) {
      direction = desiredDirection;
      // Sometimes textBoxAbsY is NaN, so we need to check for that
      if (!maxHDesired.isNaN) {
        maxHeight = maxHDesired;
      }
    } else {
      // There's not enough room in the desired direction so see how much room is in the opposite direction
      final AxisDirection flipped = flipAxisDirection(desiredDirection);
      final double maxHFlipped = _calculateMaxHeight(flipped, box, widget, windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY);

      // if there's more room in this opposite direction, update the direction and maxHeight
      if (maxHFlipped > maxHDesired) {
        direction = flipped;

        // Not sure if this is needed, but it's here just in case
        if (!maxHFlipped.isNaN) {
          maxHeight = maxHFlipped;
        }
      }
    }

    if (maxHeight < 0) maxHeight = 0;
  }

  double _calculateMaxHeight(AxisDirection direction, RenderBox box, TypeAheadField widget, double windowHeight, MediaQuery rootMediaQuery, double keyboardHeight, double textBoxAbsY) {
    return direction == AxisDirection.down ? _calculateMaxHeightDown(box, widget, windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY) : _calculateMaxHeightUp(box, widget, windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY);
  }

  double _calculateMaxHeightDown(RenderBox box, TypeAheadField widget, double windowHeight, MediaQuery rootMediaQuery, double keyboardHeight, double textBoxAbsY) {
    // unsafe area, ie: iPhone X 'home button'
    // keyboardHeight includes unsafeAreaHeight, if keyboard is showing, set to 0
    final double unsafeAreaHeight = keyboardHeight == 0 ? rootMediaQuery.data.padding.bottom : 0;

    return windowHeight - keyboardHeight - unsafeAreaHeight - textBoxHeight - textBoxAbsY - 2 * widget.suggestionsBoxVerticalOffset;
  }

  double _calculateMaxHeightUp(RenderBox box, TypeAheadField widget, double windowHeight, MediaQuery rootMediaQuery, double keyboardHeight, double textBoxAbsY) {
    // recalculate keyboard absolute y value
    final double keyboardAbsY = windowHeight - keyboardHeight;

    directionUpOffset = textBoxAbsY > keyboardAbsY ? keyboardAbsY - textBoxAbsY - widget.suggestionsBoxVerticalOffset : -widget.suggestionsBoxVerticalOffset;

    // unsafe area, ie: iPhone X notch
    final double unsafeAreaHeight = rootMediaQuery.data.padding.top;

    return textBoxAbsY > keyboardAbsY ? keyboardAbsY - unsafeAreaHeight - 2 * widget.suggestionsBoxVerticalOffset : textBoxAbsY - unsafeAreaHeight - 2 * widget.suggestionsBoxVerticalOffset;
  }

  Future<void> onChangeMetrics() async {
    if (await _waitChangeMetrics()) {
      resize();
    }
  }
}
