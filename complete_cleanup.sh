#!/bin/bash

echo "Complete repository cleanup - keeping only pattern starting May 11, 2025"
echo ""

# First, let's see what we have
echo "Current commit range:"
FIRST=$(git log --format="%ad" --date=short --reverse | head -1)
LAST=$(git log --format="%ad" --date=short | head -1)
echo "First commit: $FIRST"
echo "Last commit: $LAST"
echo ""

# Find commits to keep (on or after May 11, 2025)
KEEP_COMMITS=$(git log --format="%H" --after="2025-05-10 23:59:59" --reverse)
KEEP_COUNT=$(echo "$KEEP_COMMITS" | wc -l)

# Find commits to remove (before May 11, 2025)
REMOVE_COUNT=$(git log --format="%H" --before="2025-05-11 00:00:00" | wc -l)

echo "Commits to keep: $KEEP_COUNT (from May 11, 2025 onward)"
echo "Commits to remove: $REMOVE_COUNT (before May 11, 2025)"
echo ""

if [ "$REMOVE_COUNT" -eq 0 ]; then
    echo "No commits to remove!"
    exit 0
fi

read -p "Proceed with cleanup? This will rewrite history! (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    # Create a new branch with only the commits we want
    echo "Creating clean branch..."
    
    # Get the initial commit
    INITIAL_COMMIT=$(git rev-list --max-parents=0 HEAD)
    
    # Create new orphan branch
    git checkout --orphan clean-history
    
    # Remove all files
    git rm -rf .
    
    # Recreate initial commit
    echo "# say-my-name" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Cherry-pick all commits from May 11 onward
    echo "Applying commits from May 11, 2025 onward..."
    for commit in $KEEP_COMMITS; do
        git cherry-pick $commit
    done
    
    # Replace main branch
    git branch -D main
    git branch -m main
    
    echo ""
    echo "Cleanup complete!"
    echo "Force push with: git push --force origin main"
else
    echo "Cancelled"
fi