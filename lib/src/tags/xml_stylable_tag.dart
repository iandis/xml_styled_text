part of xml_tag;

abstract class XmlStylableTag extends XmlTag {
  const XmlStylableTag({Object? id}) : super(id: id);

  TextStyle? get style;

  @override
  InlineSpan buildSpan(String text) {
    return TextSpan(
      text: text,
      style: style,
    );
  }
}

class _XmlStylableTag extends XmlStylableTag {
  const _XmlStylableTag({
    Object? id,
    required this.style,
  }) : super(id: id);

  @override
  final TextStyle style;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextStyle>('style', style));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _XmlStylableTag && other.id == id && other.style == style;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, style);
}
