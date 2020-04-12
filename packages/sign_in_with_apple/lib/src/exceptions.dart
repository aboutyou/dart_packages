import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// A more specific [PlatformException] which describes any potential native errors that occur within the Sign in with Apple plugin.
///
/// Implementations:
/// - [SignInWithAppleNotSupportedException]
/// - [SignInWithAppleAuthorizationError]
/// - [UnknownSignInWithAppleException]
@immutable
abstract class SignInWithAppleException implements Exception {
  factory SignInWithAppleException.fromPlatformException(
    PlatformException exception,
  ) {
    switch (exception.code) {
      case 'not-supported':
        return SignInWithAppleNotSupportedException(
          message: exception.message,
        );

      /// Exceptions which indicate an [SignInWithAppleAuthorizationError]
      case 'authorization-error/unknown':
        return SignInWithAppleAuthorizationError(
          code: AuthorizationErrorCode.unknown,
          message: exception.message,
        );
      case 'authorization-error/canceled':
        return SignInWithAppleAuthorizationError(
          code: AuthorizationErrorCode.canceled,
          message: exception.message,
        );
      case 'authorization-error/invalidResponse':
        return SignInWithAppleAuthorizationError(
          code: AuthorizationErrorCode.invalidResponse,
          message: exception.message,
        );
      case 'authorization-error/notHandled':
        return SignInWithAppleAuthorizationError(
          code: AuthorizationErrorCode.notHandled,
          message: exception.message,
        );
      case 'authorization-error/failed':
        return SignInWithAppleAuthorizationError(
          code: AuthorizationErrorCode.failed,
          message: exception.message,
        );

      case 'credentials-error':
        return SignInWithAppleCredentialsException(
          message: exception.message,
        );

      default:
        return UnknownSignInWithAppleException(
          platformException: exception,
        );
    }
  }
}

/// An [SignInWithAppleException] which will be thrown if a [PlatformException]
/// can't be mapped to a more specific [SignInWithAppleException].
class UnknownSignInWithAppleException extends PlatformException
    implements SignInWithAppleException {
  UnknownSignInWithAppleException({
    @required PlatformException platformException,
  }) : super(
          code: platformException.code,
          message: platformException.message,
          details: platformException.details,
        );

  @override
  String toString() =>
      'UnknownSignInWithAppleException($code, $message, $details)';
}

/// An [SignInWithAppleException] which will be thrown in case Sign in with Apple is not supported.
class SignInWithAppleNotSupportedException implements SignInWithAppleException {
  const SignInWithAppleNotSupportedException({
    @required this.message,
  }) : assert(message != null);

  /// A message specifying more details about why Sign in with Apple is not supported
  final String message;

  @override
  String toString() => 'SignInWithAppleNotSupportedException($message)';
}

/// A description of why the authorization failed on the native side.
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorizationerror/code
enum AuthorizationErrorCode {
  /// The user canceled the authorization attempt.
  canceled,

  /// The authorization attempt failed.
  failed,

  /// The authorization request received an invalid response.
  invalidResponse,

  /// The authorization request wasn’t handled.
  notHandled,

  /// The authorization attempt failed for an unknown reason.
  unknown,
}

/// A [SignInWithAppleException] indicating something went wrong while authenticating.
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorizationerror
class SignInWithAppleAuthorizationError implements SignInWithAppleException {
  const SignInWithAppleAuthorizationError({
    @required this.code,
    @required this.message,
  })  : assert(code != null),
        assert(message != null);

  /// A more exact code of what actually went wrong
  final AuthorizationErrorCode code;

  /// A localized message of the error
  final String message;

  @override
  String toString() => 'SignInWithAppleAuthorizationError($code, $message)';
}

class SignInWithAppleCredentialsException implements SignInWithAppleException {
  const SignInWithAppleCredentialsException({
    @required this.message,
  }) : assert(message != null);

  /// The localized error message from the native code.
  final String message;

  @override
  String toString() => 'SignInWithAppleCredentialsException($message)';
}
