#!/bin/bash

# Find all commits on January 13, 2025
echo "Finding commits on January 13, 2025..."
COMMITS=$(git log --format="%H" --after="2025-01-12 23:59:59" --before="2025-01-14 00:00:00")

if [ -z "$COMMITS" ]; then
    echo "No commits found on January 13, 2025"
    exit 0
fi

echo "Found these commits to remove:"
for commit in $COMMITS; do
    git log -1 --oneline $commit
done

echo ""
read -p "Remove these commits? This cannot be undone! (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    # We need to rebase and drop these commits
    # First, find the commit before the first one we want to remove
    FIRST_TO_REMOVE=$(echo "$COMMITS" | tail -1)
    REBASE_ONTO=$(git log -1 --pretty=%P $FIRST_TO_REMOVE | cut -d' ' -f1)
    
    echo "Creating rebase script..."
    # Create a rebase todo that drops the January 13 commits
    git rebase -i $REBASE_ONTO --rebase-merges
else
    echo "Cancelled"
fi