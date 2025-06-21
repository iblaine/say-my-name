#!/bin/bash

# Get the hash of the last commit we want to keep (the one right before May 11, 2025)
LAST_KEEP=$(git log --format="%H %ad" --date=short | awk '$2 >= "2025-05-11"' | tail -1 | cut -d' ' -f1)

if [ -z "$LAST_KEEP" ]; then
    echo "No commits found on or after 2025-05-11"
    exit 1
fi

# Get the parent of that commit (this will be our new starting point)
RESET_TO=$(git log -1 --pretty=%P $LAST_KEEP | cut -d' ' -f1)

if [ -z "$RESET_TO" ]; then
    echo "Could not find parent commit"
    exit 1
fi

echo "Will reset to commit: $RESET_TO"
echo "This will remove all commits before 2025-05-11"
echo ""
read -p "Are you sure? This cannot be undone! (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    git reset --hard $RESET_TO
    echo "Reset complete. You may need to force push with: git push --force"
else
    echo "Cancelled"
fi