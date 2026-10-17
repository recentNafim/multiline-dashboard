import 'dart:js_interop';

@JS('generateProductPresentation')
external JSPromise<JSBoolean> _generateProductPresentation(
  JSAny products, JSString fileName,
);

Future<void> generateProductPresentation(
  List<Map<String, Object?>> products, String fileName,
) async {
  final JSAny? data = products.jsify();
  if (data == null) throw Exception('Cannot convert products to JavaScript');
  await _generateProductPresentation(data, fileName.toJS).toDart;
}
