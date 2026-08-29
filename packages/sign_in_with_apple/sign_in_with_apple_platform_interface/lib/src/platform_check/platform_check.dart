// `dart:io` must not be imported when compiling for the web (in particular
// WebAssembly, where it is unavailable), so the platform checks are selected
// via a conditional export instead — mirroring `package:flutter/foundation.dart`.
export 'platform_check_io.dart'
    if (dart.library.js_interop) 'platform_check_web.dart';
