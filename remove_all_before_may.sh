#!/bin/bash

echo "This will remove ALL commits before May 11, 2025"
echo "These are all from previous runs of the script"
echo ""

# Count commits before May 11, 2025
COUNT=$(git log --format="%H" --before="2025-05-11 00:00:00" | wc -l)
echo "Found $COUNT commits before May 11, 2025"

if [ "$COUNT" -eq 0 ]; then
    echo "No commits to remove"
    exit 0
fi

# Show what will be removed
echo ""
echo "Date range of commits to be removed:"
git log --format="%ad" --date=short --before="2025-05-11 00:00:00" | sort | uniq -c

echo ""
read -p "Remove ALL these commits? This cannot be undone! (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    # Find the first commit on or after May 11, 2025
    FIRST_KEEP=$(git log --format="%H" --after="2025-05-10 23:59:59" --reverse | head -1)
    
    if [ -z "$FIRST_KEEP" ]; then
        echo "No commits found on or after May 11, 2025"
        exit 1
    fi
    
    echo "Resetting to keep only commits from May 11, 2025 onward..."
    git reset --hard $FIRST_KEEP
    
    # Clean up the commits directory
    rm -rf commits/2024-*
    rm -rf commits/2025-0[1-4]-*
    rm -f commits/2025-05-0*
    rm -f commits/2025-05-10*
    
    echo "Reset complete!"
    echo "You'll need to force push with: git push --force"
else
    echo "Cancelled"
fi