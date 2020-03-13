enum CredentialState {
  authorized,
  revoked,
  notFound,
}

CredentialState parseCredentialState(String credentialState) {
  switch (credentialState) {
    case 'authorized':
      return CredentialState.authorized;

    case 'revoked':
      return CredentialState.revoked;

    case 'notFound':
      return CredentialState.notFound;

    default:
      throw Exception('Unsupported credential state $credentialState');
  }
}
