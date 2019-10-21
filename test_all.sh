set -eu

cd packages/state_queue
flutter test
cd ../..

cd packages/with_bloc
flutter test
cd ../..