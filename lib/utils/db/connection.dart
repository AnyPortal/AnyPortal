// We use a conditional export to expose the right connection factory depending
// on the platform.
export 'connection/unsupported.dart'
    if (dart.library.js_interop) 'connection/web.dart'
    if (dart.library.ffi) 'connection/native.dart';