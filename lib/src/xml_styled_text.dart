import 'package:xml/xml_events.dart'
    show XmlEvent, XmlNodeDecoder, parseEvents;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

import 'tags/xml_tag.dart';
import 'default_xml_tags.dart';

typedef XmlTagMap = Map<String, XmlTag>;

/// A [Widget] that can render a text containing XML tags.
///
/// Example:
/// ```dart
/// const String hi = 'Hello, <b>World</b>!';
/// return XmlStyledText(
///   text: hi,
///   tags: <String, XmlTag>{
///     'b': XmlTag.stylable(
///         style: const TextStyle(fontWeight: FontWeight.bold),
///      ),
///   },
/// );
/// ```
/// This will render: Hello, **World**!
class XmlStyledText extends StatefulWidget {
  const XmlStyledText({
    Key? key,
    required this.text,
    this.tags,
    this.maxLines,
    this.style,
    this.textAlign,
    this.overflow,
    this.locale,
    this.softWrap,
    this.textScaleFactor,
    this.textDirection,
    this.textHeightBehavior,
    this.textWidthBasis,
    this.strutStyle,
  }) : super(key: key);

  @visibleForTesting
  static XmlDocument parse(String text) {
    final Iterable<XmlEvent> events = parseEvents(
      text,
      validateNesting: true,
      // we explicitly declare these arguments
      // to avoid potential breaking changes in the future
      entityMapping: null,
      validateDocument: false,
      withBuffer: false,
      withLocation: false,
      withParent: false,
    );
    // We can safely ignore this because we just need to copy [XmlDocument.parse]
    // implementation and disable document validation.
    // ignore: invalid_use_of_internal_member
    return XmlDocument(const XmlNodeDecoder().convertIterable(events));
  }

  final String text;

  final XmlTagMap? tags;

  final int? maxLines;

  final TextStyle? style;

  final TextAlign? textAlign;

  final TextOverflow? overflow;

  final Locale? locale;

  final bool? softWrap;

  final double? textScaleFactor;

  final TextDirection? textDirection;

  final TextHeightBehavior? textHeightBehavior;

  final TextWidthBasis? textWidthBasis;

  final StrutStyle? strutStyle;

  XmlTagMap get _tags => tags ?? const <String, XmlTag>{};

  @override
  State<XmlStyledText> createState() => _XmlStyledTextState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(DiagnosticsProperty<XmlTagMap>('tags', tags, defaultValue: null))
      ..add(IntProperty('maxLines', maxLines, defaultValue: null))
      ..add(DiagnosticsProperty<TextStyle>('style', style, defaultValue: null))
      ..add(DiagnosticsProperty<TextAlign>(
        'textAlign',
        textAlign,
        defaultValue: null,
      ))
      ..add(DiagnosticsProperty<TextOverflow>(
        'overflow',
        overflow,
        defaultValue: null,
      ))
      ..add(DiagnosticsProperty<Locale>('locale', locale, defaultValue: null))
      ..add(FlagProperty(
        'softWrap',
        value: softWrap,
        ifTrue: 'wrapping at box width',
        ifFalse: 'no wrapping except at line break characters',
        showName: true,
      ))
      ..add(DoubleProperty(
        'textScaleFactor',
        textScaleFactor,
        defaultValue: null,
      ))
      ..add(DiagnosticsProperty<TextDirection>(
        'textDirection',
        textDirection,
        defaultValue: null,
      ))
      ..add(DiagnosticsProperty<TextHeightBehavior>(
        'textHeightBehavior',
        textHeightBehavior,
        defaultValue: null,
      ))
      ..add(DiagnosticsProperty<TextWidthBasis>(
        'textWidthBasis',
        textWidthBasis,
      ))
      ..add(DiagnosticsProperty<StrutStyle>('strutStyle', strutStyle));
  }
}

class _XmlStyledTextState extends State<XmlStyledText> {
  bool _isInitialized = false;

  XmlTagMap? _defaultTags;
  List<XmlTag>? _tagList;
  List<InlineSpan>? _spans;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final XmlTagMap? previousDefaultTags = _defaultTags;
    _defaultTags = DefaultXmlTags.of(context);

    if (!_isInitialized) {
      _initSpans();
      _isInitialized = true;
    } else if (!mapEquals(previousDefaultTags, _defaultTags)) {
      _updateSpans();
    }
  }

  @override
  void didUpdateWidget(covariant XmlStyledText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        !mapEquals(oldWidget._tags, widget._tags)) {
      _updateSpans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan>? spans = _spans;
    if (spans == null) return const SizedBox.shrink();

    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style;
    if (widget.style == null || widget.style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }
    if (MediaQuery.boldTextOf(context)) {
      effectiveTextStyle = effectiveTextStyle!.merge(
        const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    final TextAlign textAlign =
        widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;

    final double textScaleFactor =
        widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);

    return RichText(
      textAlign: textAlign,
      maxLines: widget.maxLines ?? defaultTextStyle.maxLines,
      overflow: widget.overflow ??
          effectiveTextStyle?.overflow ??
          defaultTextStyle.overflow,
      // RichText uses Localizations.localeOf to obtain a default if this is null
      locale: widget.locale,
      softWrap: widget.softWrap ?? defaultTextStyle.softWrap,
      textScaleFactor: textScaleFactor,
      // RichText uses Directionality.of to obtain a default if this is null.
      textDirection: widget.textDirection,
      textWidthBasis: widget.textWidthBasis ?? defaultTextStyle.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior ??
          defaultTextStyle.textHeightBehavior ??
          DefaultTextHeightBehavior.maybeOf(context),
      strutStyle: widget.strutStyle,
      text: TextSpan(
        style: effectiveTextStyle,
        children: spans,
      ),
    );
  }

  @override
  void dispose() {
    _disposeTags();
    super.dispose();
  }

  void _initSpans() {
    final XmlTagMap widgetTags = widget._tags;
    final XmlTagMap defaultTags = _defaultTags ?? const <String, XmlTag>{};

    if (widgetTags.isEmpty && defaultTags.isEmpty) {
      _spans = <InlineSpan>[TextSpan(text: widget.text)];
      return;
    }

    final XmlDocument document = XmlStyledText.parse(widget.text);

    final List<XmlTag> tagList = <XmlTag>[];
    final List<InlineSpan> spans = <InlineSpan>[];

    for (final XmlNode node in document.children) {
      if (node is XmlText) {
        spans.add(TextSpan(text: node.text));
      } else if (node is XmlElement) {
        final String xmlTagName = node.name.local;
        final XmlTag? tag = widgetTags[xmlTagName];
        if (tag != null) {
          tagList.add(tag);
          spans.add(tag.buildSpan(node.text));
        } else {
          final XmlTag? defaultTag = defaultTags[xmlTagName];
          spans.add(
            defaultTag?.buildSpan(node.text) ?? TextSpan(text: node.text),
          );
        }
      }
    }

    _tagList = tagList;
    _spans = spans;
  }

  void _updateSpans() {
    _disposeTags();
    _initSpans();
  }

  void _disposeTags() {
    if (_tagList == null) return;
    for (final XmlTag tag in _tagList!) {
      tag.dispose();
    }
    _tagList = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty(
        '_isInitialized',
        value: _isInitialized,
        ifTrue: 'spans initialized',
        ifFalse: 'didChangeDependencies has not been called',
      ))
      ..add(DiagnosticsProperty<XmlTagMap>('_defaultTags', _defaultTags))
      ..add(DiagnosticsProperty<List<XmlTag>>('_tagList', _tagList))
      ..add(DiagnosticsProperty<List<InlineSpan>>('_spans', _spans));
  }
}
