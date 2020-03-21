#!/bin/sh

set -eux
    
cd packages/state_queue
flutter packages get
cd ../..

cd packages/with_bloc
flutter packages get
cd ../..

cd packages/pending_operations
flutter packages get
cd ../..

cd packages/sign_in_with_apple
flutter packages get
cd ../..