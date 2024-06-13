part of xml_tag;

abstract class XmlClickableTag extends XmlTag {
  const XmlClickableTag({Object? id}) : super(id: id);

  GestureRecognizer? get recognizer;

  @override
  InlineSpan buildSpan(String text) {
    return TextSpan(
      text: text,
      recognizer: recognizer,
    );
  }
}

class _XmlSingleTapClickableTag extends XmlClickableTag {
  _XmlSingleTapClickableTag({
    Object? id,
    required this.onTap,
  }) : super(id: id);

  final VoidCallback onTap;

  GestureRecognizer? _recognizer;

  @override
  GestureRecognizer get recognizer {
    if (_recognizer != null) dispose();
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
    properties.add(DiagnosticsProperty<VoidCallback>('onTap', onTap));
    properties.add(DiagnosticsProperty<GestureRecognizer>(
      'recognizer',
      _recognizer,
    ));
  }
}
