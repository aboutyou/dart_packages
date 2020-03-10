#!/bin/sh

set -eux

cd packages/state_queue
flutter analyze
cd ../..

cd packages/with_bloc
flutter analyze
cd ../..

cd packages/pending_operations
flutter analyze
cd ../..

cd packages/sign_in_with_apple
flutter analyze
cd ../..