import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'xml_styled_text.dart';

class DefaultXmlTags extends InheritedWidget {
  const DefaultXmlTags({
    Key? key,
    required this.tags,
    required Widget child,
  }) : super(key: key, child: child);

  static XmlTagMap? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DefaultXmlTags>()?.tags;
  }

  final XmlTagMap tags;

  @override
  bool updateShouldNotify(covariant DefaultXmlTags oldWidget) {
    return !mapEquals(oldWidget.tags, tags);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<XmlTagMap>('tags', tags));
  }
}
