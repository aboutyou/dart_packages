## 2.1.0

- Support compiling to WebAssembly: `dart:io` is no longer imported unconditionally, which previously made the whole `sign_in_with_apple` package family score as WASM-incompatible on pub.dev
  - The platform checks now use a conditional import (mirroring `package:flutter/foundation.dart`), with unchanged behavior on all native platforms and in `flutter test`

## 2.0.0

- Adds `credentialExport`, `credentialImport`, and `matchedExcludedCredential` cases to `AuthorizationErrorCode`

## 1.1.0

- Use proper type name in toString
- Set min Flutter SDK to 3.19.0

## 1.0.0

- Initial open-source release.
