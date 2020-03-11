set -eu

cd packages/state_queue
flutter test
cd ../..

cd packages/with_bloc
flutter test
cd ../..

cd packages/sign_in_with_apple
ls
find .
flutter test
cd ../..