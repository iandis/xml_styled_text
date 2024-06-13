library xml_tag;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import '../xml_styled_text.dart';

part 'xml_clickable_tag.dart';
part 'xml_span_tag.dart';
part 'xml_stylable_tag.dart';

abstract class XmlTag with Diagnosticable {
  const XmlTag({this.id});

  /// Creates an [XmlSpanTag] that can be both styled and clicked.
  ///
  /// The [onTap] callback will be called when the text is tapped.
  /// The [style] will be applied to the text.
  ///
  /// Notes: for better performance, consider passing [id] to the [XmlSpanTag]
  /// so that every time the text is being rebuilt by the [XmlStyledText],
  /// it doesn't need to parse the XML again if the [onTap] callback is the same.
  factory XmlTag.span({
    Object? id,
    TextStyle? style,
    VoidCallback? onTap,
  }) = _XmlSpanTag;

  /// Creates an [XmlStylableTag] that can only be styled.
  ///
  /// The [style] will be applied to the text.
  const factory XmlTag.stylable({
    Object? id,
    required TextStyle style,
  }) = _XmlStylableTag;

  /// Creates an [XmlClickableTag] that can be clicked.
  ///
  /// The [onTap] callback will be called when the text is tapped.
  ///
  /// Notes: for better performance, consider passing [id] to the [XmlClickableTag]
  /// so that every time the text is being rebuilt by the [XmlStyledText],
  /// it doesn't need to parse the XML again if the [onTap] callback is the same.
  factory XmlTag.clickable({
    Object? id,
    required VoidCallback onTap,
  }) = _XmlSingleTapClickableTag;

  final Object? id;

  InlineSpan buildSpan(String text);

  /// Releases any resources used by [XmlTag].
  void dispose() {}

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', id));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is XmlTag && other.runtimeType == runtimeType && other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);
}
