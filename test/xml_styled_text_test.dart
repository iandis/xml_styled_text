import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml_styled_text/xml_styled_text.dart';

Widget _wrapWithDirectionality(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );
}

void main() {
  group('[XmlStyledText] Test Xml Document parser:', () {
    test(
      'Should not throw any error when parsing text with no xml tags',
      () {
        expect(
          () => XmlStyledText.parse('test'),
          returnsNormally,
        );
      },
    );

    test(
      'Should not throw any error when parsing text with valid xml tags',
      () {
        expect(
          () => XmlStyledText.parse('<b>test</b>'),
          returnsNormally,
        );

        expect(
          () => XmlStyledText.parse('<b><c>test</c></b>'),
          returnsNormally,
        );
      },
    );
  });

  group(
    '[XmlStyledText] Test parser when [DefaultXmlTags] widget is above [XmlStyledText]:',
    () {
      Widget wrapWithDefaultXmlTags(Widget child) {
        return _wrapWithDirectionality(
          DefaultXmlTags(
            tags: const <String, XmlTag>{
              'b': XmlTag.stylable(
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            },
            child: child,
          ),
        );
      }

      testWidgets(
        'Should render normally when building a text containing no xml tags',
        (WidgetTester tester) async {
          await tester.pumpWidget(wrapWithDefaultXmlTags(
            const XmlStyledText(text: 'Hello world!'),
          ));

          expect(
            TestWidgetsFlutterBinding.instance.takeException(),
            isNull,
          );
        },
      );

      testWidgets(
        'Should render with the style defined by the [DefaultXmlTags] widget',
        (WidgetTester widgetTester) async {
          await widgetTester.pumpWidget(wrapWithDefaultXmlTags(
            const XmlStyledText(text: 'Hello <b>world</b>!'),
          ));

          expect(find.text('Hello world!', findRichText: true), findsOneWidget);
          expect(
            find.byWidgetPredicate(
              (Widget widget) {
                if (widget is! RichText) return false;

                final InlineSpan span = widget.text;
                if (span is! TextSpan) return false;

                final List<InlineSpan>? children = span.children;
                if (children == null) return false;

                return children.length == 3 &&
                    children[1] is TextSpan &&
                    children[1].style?.fontWeight == FontWeight.bold &&
                    (children[1] as TextSpan).text == 'world';
              },
              description: 'RichText',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Should render the clickable text with [TapGestureRecognizer]',
        (WidgetTester widgetTester) async {
          int tapCount = 0;
          void onTap() => tapCount++;

          await widgetTester.pumpWidget(wrapWithDefaultXmlTags(
            XmlStyledText(
              text: 'Hello <link>world</link>!',
              tags: <String, XmlTag>{
                'link': XmlTag.clickable(onTap: onTap),
              },
            ),
          ));

          bool isTextSpanTapped(TextSpan span) {
            if (span.recognizer is TapGestureRecognizer) {
              (span.recognizer as TapGestureRecognizer).onTap!();
              return true;
            }
            return false;
          }

          expect(
            find.byWidgetPredicate(
              (Widget widget) {
                if (widget is! RichText) return false;

                final InlineSpan span = widget.text;
                if (span is! TextSpan) return false;

                final List<InlineSpan>? children = span.children;
                if (children == null) return false;

                return children.length == 3 &&
                    children[1] is TextSpan &&
                    children[1].style == null &&
                    isTextSpanTapped(children[1] as TextSpan) &&
                    (children[1] as TextSpan).text == 'world';
              },
              description: 'RichText',
            ),
            findsOneWidget,
          );

          expect(tapCount, equals(1));
        },
      );

      testWidgets(
        'Should render the text with the style defined by the caller '
        'when caller provides [tags] to [XmlStyledText] with the same tag name defined in [DefaultXmlTags]',
        (WidgetTester widgetTester) async {
          await widgetTester.pumpWidget(wrapWithDefaultXmlTags(
            const XmlStyledText(
              text: 'Hello <b>world</b>!',
              tags: <String, XmlTag>{
                'b': XmlTag.stylable(
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              },
            ),
          ));

          expect(
            find.byWidgetPredicate(
              (Widget widget) {
                if (widget is! RichText) return false;

                final InlineSpan span = widget.text;
                if (span is! TextSpan) return false;

                final List<InlineSpan>? children = span.children;
                if (children == null) return false;

                return children.length == 3 &&
                    children[1] is TextSpan &&
                    children[1].style?.color == Colors.amber &&
                    children[1].style?.fontWeight == FontWeight.w900 &&
                    (children[1] as TextSpan).text == 'world';
              },
              description: 'RichText',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Should render the text without the xml tags and without any styling '
        'when containing undefined xml tags',
        (WidgetTester widgetTester) async {
          await widgetTester.pumpWidget(wrapWithDefaultXmlTags(
            const XmlStyledText(text: 'Hello <bp>world</bp>!'),
          ));

          expect(find.text('Hello world!', findRichText: true), findsOneWidget);
          expect(
            find.byWidgetPredicate(
              (Widget widget) {
                if (widget is! RichText) return false;

                final InlineSpan span = widget.text;
                if (span is! TextSpan) return false;

                final List<InlineSpan>? children = span.children;
                if (children == null) return false;

                return children.length == 3 &&
                    children[1] is TextSpan &&
                    children[1].style == null &&
                    (children[1] as TextSpan).text == 'world';
              },
              description: 'RichText',
            ),
            findsOneWidget,
          );
        },
      );
    },
  );

  group(
    '[XmlStyledText] Test parser when no [DefaultXmlTags] widget is above [XmlStyledText]:',
    () {
      testWidgets(
        'Should render text normally when containing no xml tags',
        (WidgetTester tester) async {
          await tester.pumpWidget(_wrapWithDirectionality(
            const XmlStyledText(text: 'Hello world!'),
          ));

          expect(
            TestWidgetsFlutterBinding.instance.takeException(),
            isNull,
          );
        },
      );

      testWidgets(
        'Should render the raw text without any styling '
        'when building a text containing xml styling tags',
        (WidgetTester widgetTester) async {
          await widgetTester.pumpWidget(_wrapWithDirectionality(
            const XmlStyledText(text: 'Hello <b>world</b>!'),
          ));

          expect(
            find.text('Hello <b>world</b>!', findRichText: true),
            findsOneWidget,
          );
          expect(
            find.byWidgetPredicate(
              (Widget widget) {
                if (widget is! RichText) return false;

                final InlineSpan span = widget.text;
                if (span is! TextSpan) return false;

                final List<InlineSpan>? children = span.children;
                if (children == null) return false;
                return children.length == 1 &&
                    children[0] is TextSpan &&
                    children[0].style == null &&
                    (children[0] as TextSpan).text == 'Hello <b>world</b>!';
              },
              description: 'RichText',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Should render the text with the style defined by the caller when caller provides [tags] to [XmlStyledText]',
        (WidgetTester widgetTester) async {
          await widgetTester.pumpWidget(_wrapWithDirectionality(
            const XmlStyledText(
              text: 'Hello <b>world</b>!',
              tags: <String, XmlTag>{
                'b': XmlTag.stylable(
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              },
            ),
          ));

          expect(find.text('Hello world!', findRichText: true), findsOneWidget);
          expect(
            find.byWidgetPredicate(
              (Widget widget) {
                if (widget is! RichText) return false;

                final InlineSpan span = widget.text;
                if (span is! TextSpan) return false;

                final List<InlineSpan>? children = span.children;
                if (children == null) return false;
                return children.length == 3 &&
                    children[1] is TextSpan &&
                    children[1].style?.fontWeight == FontWeight.bold &&
                    (children[1] as TextSpan).text == 'world';
              },
              description: 'RichText',
            ),
            findsOneWidget,
          );
        },
      );
    },
  );
}
