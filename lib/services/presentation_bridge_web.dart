

import 'dart:js_interop';

@JS('generateProductPresentation')
external JSPromise<JSBoolean> _generateProductPresentation(
    JSAny products,
    JSString fileName,
    );

Future<void> generateProductPresentation(
    List<Map<String, Object?>> products,
    String fileName,
    ) async {
  final JSAny? jsProducts = products.jsify();

  if (jsProducts == null) {
    throw Exception(
      'Could not convert product data to JavaScript.',
    );
  }

  await _generateProductPresentation(
    jsProducts,
    fileName.toJS,
  ).toDart;
}