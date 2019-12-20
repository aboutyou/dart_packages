#!/bin/sh

set -eu

# iff GITHUB_ACTIONS=true
su - root

cd packages/state_queue
flutter packages get
cd ../..

cd packages/with_bloc
flutter packages get
cd ../..

cd packages/pending_operations
flutter packages get
cd ../..