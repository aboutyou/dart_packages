import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// A more specific [PlatformException] which describes any potential native errors that occur within the Sign in with Apple plugin.
///
/// Implementations:
/// - [SignInWithAppleNotSupportedException]
/// - [SignInWithAppleAuthorizationException]
/// - [UnknownSignInWithAppleException]
@immutable
abstract class SignInWithAppleException implements Exception {
  factory SignInWithAppleException.fromPlatformException(
    PlatformException exception,
  ) {
    switch (exception.code) {
      case 'not-supported':
        return SignInWithAppleNotSupportedException(
          message: exception.message ?? 'no message provided',
        );

      /// Exceptions which indicate an [SignInWithAppleAuthorizationError]
      case 'authorization-error/unknown':
        return SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.unknown,
          message: exception.message ?? 'no message provided',
        );
      case 'authorization-error/canceled':
        return SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled,
          message: exception.message ?? 'no message provided',
        );
      case 'authorization-error/invalidResponse':
        return SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.invalidResponse,
          message: exception.message ?? 'no message provided',
        );
      case 'authorization-error/notHandled':
        return SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.notHandled,
          message: exception.message ?? 'no message provided',
        );
      case 'authorization-error/notInteractive':
        return SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.notInteractive,
          message: exception.message ?? 'no message provided',
        );
      case 'authorization-error/failed':
        return SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.failed,
          message: exception.message ?? 'no message provided',
        );

      case 'credentials-error':
        return SignInWithAppleCredentialsException(
          message: exception.message ?? 'no message provided',
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
    required PlatformException platformException,
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
    required this.message,
  });

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

  /// The authorization request isn’t interactive.
  notInteractive,

  /// The authorization attempt failed for an unknown reason.
  unknown,
}

/// A [SignInWithAppleException] indicating something went wrong while authenticating.
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorizationerror
class SignInWithAppleAuthorizationException
    implements SignInWithAppleException {
  const SignInWithAppleAuthorizationException({
    required this.code,
    required this.message,
  });

  /// A more exact code of what actually went wrong
  final AuthorizationErrorCode code;

  /// A localized message of the error
  final String message;

  @override
  String toString() => 'SignInWithAppleAuthorizationError($code, $message)';
}

class SignInWithAppleCredentialsException implements SignInWithAppleException {
  const SignInWithAppleCredentialsException({
    required this.message,
  });

  /// The localized error message from the native code.
  final String message;

  @override
  String toString() => 'SignInWithAppleCredentialsException($message)';
}
