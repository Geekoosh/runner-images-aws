#!/bin/bash

# Exit on any error
set -e

# 1. Check if the upstream remote is already set
UPSTREAM_REPO="https://github.com/actions/runner-images.git"
if git remote | grep -q "^upstream$"; then
    echo "Upstream remote already set."
else
    git remote add upstream "$UPSTREAM_REPO"
    echo "Upstream remote set to $UPSTREAM_REPO."
fi

# 2. Fetch tags from the upstream repository
git fetch upstream --tags

# 3. Find the latest tag starting with 'ubuntu22'
LATEST_TAG=$(git tag -l 'ubuntu*' --sort=-v:refname | head -n 1)
if [ -z "$LATEST_TAG" ]; then
    echo "No tags found starting with 'ubuntu22'"
    exit 1
fi
echo "Latest tag found: $LATEST_TAG"

# 4. Create a new branch from the latest tag
NEW_BRANCH="branch-from-$LATEST_TAG"
git checkout -b "$NEW_BRANCH" "$LATEST_TAG"

# 5. Merge the new branch into main
git checkout main
git merge "$NEW_BRANCH"
