#!/bin/sh

set -eux

# iff GITHUB_ACTIONS=true
#su - root

whoami

pwd



# sudo -i -u root

cd packages/state_queue
flutter packages get
cd ../..

cd packages/with_bloc
flutter packages get
cd ../..

cd packages/pending_operations
flutter packages get
cd ../..