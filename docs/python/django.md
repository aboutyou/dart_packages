# Django integration example

Replace {Package Name} with your package name

```
from django.http.response import HttpResponse
from urllib.parse import unquote

def apple_login(request):
   """ Post request """
    redirect = (
        f"intent://callback?{unquote(request.body)}"
        "#Intent;package={Package Name};scheme=signinwithapple;end"
    )
    response = HttpResponse("", status=307)
    response["Location"] = redirect
    return response
 ```
   
**In your flutter app Make sure to add accessToken attribute to credential**
 ```
final credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode, <--------- HERE
        rawNonce: rawNonce,
      );
 ```
