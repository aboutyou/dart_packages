# Development of the web plugin

Sign in with Apple only works on websites served with `HTTPS`, even for local development.

Thus you need to serve the Flutter development server through a reverse-proxy that adds SSL.

`mitmproxy` is an easy way to do this. To set this up on macOS follow these steps:

```sh
brew install mitmproxy

flutter run -d chrome

# Replace the port 12345 with the one Flutter is actually using in the opened Chrome window (this changes on every start)
mitmdump -p 443 --mode reverse:http://localhost:12345/

# When accessing the proxy for the first time, you need to import the certificate
open ~/.mitmproxy
# Then double click `mitmproxy-ca-cert.pem` and in `Keychain Access` app select Trust -> SSL -> Always

# Lastly you need a proper "domain", which needs to be registered with your Sign in with Apple service (in the development portal)
# as a `Domain` and `Redirect URL` each

sudo nano /etc/hosts
# add a line like:
# 127.0.0.1 siwa-flutter-plugin.dev

# Now you can finally visit your example page in the browse by executing
open "https://siwa-flutter-plugin.dev/"
```

When using the Glitch example server, the redirect URL parameter must also be set to `https://siwa-flutter-plugin.dev/` for testing the web version.
