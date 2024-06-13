part of xml_tag;

abstract class XmlSpanTag extends XmlTag
    implements XmlStylableTag, XmlClickableTag {
  const XmlSpanTag({Object? id}) : super(id: id);

  @override
  InlineSpan buildSpan(String text) {
    return TextSpan(
      text: text,
      style: style,
      recognizer: recognizer,
    );
  }
}

class _XmlSpanTag extends XmlSpanTag {
  _XmlSpanTag({
    Object? id,
    this.style,
    this.onTap,
  }) : super(id: id);

  @override
  final TextStyle? style;

  final VoidCallback? onTap;

  GestureRecognizer? _recognizer;

  @override
  GestureRecognizer? get recognizer {
    if (_recognizer != null) dispose();
    if (onTap == null) return null;
    return _recognizer = TapGestureRecognizer(debugOwner: this)..onTap = onTap;
  }

  @override
  void dispose() {
    _recognizer?.dispose();
    _recognizer = null;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TextStyle>('style', style, defaultValue: null))
      ..add(DiagnosticsProperty<VoidCallback>(
        'onTap',
        onTap,
        defaultValue: null,
      ))
      ..add(DiagnosticsProperty<GestureRecognizer>(
        'recognizer',
        _recognizer,
        defaultValue: null,
      ));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _XmlSpanTag && other.id == id && other.style == style;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, style);
}
