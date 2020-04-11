/// Parameters required for web-based authentication flows
///
/// As described in https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms
class WebAuthenticationOptions {
  WebAuthenticationOptions({
    @required this.clientId,
    @required this.redirectUri,
  });

  /// The developer’s client identifier, as provided by WWDR.
  ///
  /// This is the "service ID" parameter as shown on https://developer.apple.com/account/resources/identifiers/serviceId/edit/SERVICE_ID
  final String clientId;

  /// The URI to which the authorization redirects. It must include a domain name, and can’t be an IP address or localhost.
  ///
  /// Must be configured at https://developer.apple.com/account/resources/identifiers/list/serviceId
  final Uri redirectUri;
}
