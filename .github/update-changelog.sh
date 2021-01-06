#!/usr/bin/env bash
set -x

# We are cloned in the 'main' directory and the dj-wasabi-release
# repository is the 'dj-wasabi-release' next to 'main'
cd main

# Generate markdown
../dj-wasabi-release/release.sh -d

# Let commit the changes
git status
if [[ $(git status | grep modified | wc -l) -ge 1 ]]
  then  echo "Committing file"
        git config --global user.name 'Werner Dijkerman [GH bot]'
        git config --global user.email 'github@dj-wasabi.nl'

        git add CHANGELOG.md
        git commit -m "Updated CHANGELOG.md on \"$(date "+%Y-%m-%d %H:%M:%S")\"" CHANGELOG.md
        # git push
fi
