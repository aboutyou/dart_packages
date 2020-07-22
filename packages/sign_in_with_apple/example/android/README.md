## Testing both V1 and V2 Android Embeddings

In order to veryfy that both version of embeddings work please run here:

```bash
./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../../test/sign_in_with_apple_e2e.dart
```

End2End tests are described [here](https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration#testing-your-plugin)

