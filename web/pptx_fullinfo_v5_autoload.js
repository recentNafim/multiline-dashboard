import 'dart:async';
import 'dart:html' as html;
import 'dart:js_interop';

// V5 is loaded on demand when the Presentation button is pressed.
// No modifications to web/index.html required. Legacy PPTX JS can coexist.
@JS('displayRoomPptxV5Version')
external JSString? get _loadedV5Version;

@JS('PptxGenJS')
external JSFunction? get _pptxLibrary;

@JS('generateDisplayRoomFullInfoV5')
external JSPromise<JSBoolean> _generateV5(JSAny products, JSString name);

const String _expectedVersion = 'FULL_INFO_V5_AUTOLOAD_20261026';
const String _v5Asset = 'pptx_fullinfo_v5_autoload.js';
const String _pptxLibraryCdn =
    'https://cdn.jsdelivr.net/npm/pptxgenjs/dist/pptxgen.bundle.js';

Future<void>? _initialization;

Future<void> _insertScript(String url) async {
  final done = Completer<void>();
  final script = html.ScriptElement()..src = url;

  final onLoad = script.onLoad.listen((_) {
    if (!done.isCompleted) done.complete();
  });
  final onError = script.onError.listen((_) {
    if (!done.isCompleted) {
      done.completeError(StateError('JavaScript could not load: $url'));
    }
  });
  html.document.head!.append(script);
  try {
    await done.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw StateError('Timed out loading JavaScript: $url'),
    );
  } finally {
    await onLoad.cancel();
    await onError.cancel();
  }
}

Future<void> _loadGenerator() async {
  if (_loadedV5Version?.toDart == _expectedVersion) return;

  // Older index.html may not include pptxgenjs either.
  if (_pptxLibrary == null) {
    await _insertScript(_pptxLibraryCdn);
    if (_pptxLibrary == null) {
      throw StateError('PptxGenJS library failed to initialize. '
          'Check browser connectivity to jsdelivr.net.');
    }
  }

  // Flutter Web has <base href="/"> (or the deployed app subdirectory).
  // Resolve under the app root rather than the current hash-route.
  final assetUrl = Uri.base.resolve(
    '$_v5Asset?version=$_expectedVersion',
  ).toString();
  await _insertScript(assetUrl);

  if (_loadedV5Version?.toDart != _expectedVersion) {
    throw StateError(
      'V5 script requested but did not initialize. '
      'Check browser Network tab for $_v5Asset (HTTP 200 and JavaScript MIME), '
      'and confirm it is at <project>/web/$_v5Asset. '
      'Current version: ${_loadedV5Version?.toDart ?? "none"}',
    );
  }
}

Future<void> _ensureGenerator() async {
  if (_loadedV5Version?.toDart == _expectedVersion) return;
  _initialization ??= _loadGenerator();
  try {
    await _initialization;
  } catch (_) {
    // Allow user to fix file/network and retry without restarting Flutter.
    _initialization = null;
    rethrow;
  }
}

Future<void> generateProductPresentation(
  List<Map<String, Object?>> products,
  String fileName,
) async {
  await _ensureGenerator();
  final jsProducts = products.jsify();
  if (jsProducts == null) throw StateError('Could not encode product data.');
  await _generateV5(jsProducts, fileName.toJS).toDart;
}
