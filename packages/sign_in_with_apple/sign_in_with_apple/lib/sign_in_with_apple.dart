export 'package:sign_in_with_apple_platform_interface/sign_in_with_apple_platform_interface.dart'
    show
        AppleIDAuthorizationRequest,
        AppleIDAuthorizationScopes,
        AuthorizationCredentialAppleID,
        AuthorizationCredentialPassword,
        AuthorizationErrorCode,
        AuthorizationRequest,
        CredentialState,
        generateNonce,
        PasswordAuthorizationRequest,
        SignInWithAppleAuthorizationException,
        SignInWithAppleCredentialsException,
        SignInWithAppleException,
        SignInWithAppleNotSupportedException,
        UnknownSignInWithAppleException,
        WebAuthenticationOptions;

export './src/sign_in_with_apple.dart' show SignInWithApple;
export './src/widgets/apple_logo_painter.dart' show AppleLogoPainter;
export './src/widgets/sign_in_with_apple_builder.dart'
    show SignInWithAppleBuilder;
export './src/widgets/sign_in_with_apple_button.dart'
    show SignInWithAppleButton, SignInWithAppleButtonStyle, IconAlignment;
