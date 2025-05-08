import os
import datetime
import time
import subprocess
from pathlib import Path
from letter_patterns import letter_patterns

def commit_exists(date_str, commit_index):
    """Check if a commit exists for the given date and index."""
    try:
        result = subprocess.run(
            ["git", "log", "--before", f"{date_str} 23:59:59", "--after", f"{date_str} 00:00:00"],
            capture_output=True,
            text=True
        )
        # Count the number of commits for this date
        commit_count = len([line for line in result.stdout.split('\n') if line.startswith('commit ')])
        return commit_count > commit_index
    except subprocess.CalledProcessError:
        return False

def create_commits_for_pattern(pattern, start_date, commits_per_day=3):
    """
    Create commits based on a 2D pattern array where 1 means commit and 0 means no commit.
    Creates multiple commits per day for a darker green color.
    
    Args:
        pattern: 2D array of 0s and 1s representing the pattern
        start_date: datetime object representing the Sunday to start from
        commits_per_day: Number of commits to create per day (default: 3)
    """
    # Create commits directory if it doesn't exist
    Path("commits").mkdir(exist_ok=True)
    
    # Loop through pattern and create commits
    for week_idx, week in enumerate(pattern):
        for day_idx, should_commit in enumerate(week):
            if should_commit:
                # Calculate date for this position
                current_date = start_date + datetime.timedelta(days=day_idx, weeks=week_idx)
                date_str = current_date.strftime("%Y-%m-%d")
                
                # Create multiple commits for this day
                for commit_idx in range(commits_per_day):
                    # Skip if this commit already exists
                    if commit_exists(date_str, commit_idx):
                        print(f"Commit {commit_idx + 1} already exists for {date_str}, skipping...")
                        continue
                    
                    # Create empty commit for this date
                    commit_time = f"{8 + commit_idx * 2}:00:00"  # Space commits throughout the day
                    commit_date = f"{date_str} {commit_time}"
                    file_name = f"commits/{date_str}_{commit_idx}.txt"
                    
                    # Create and add file
                    Path(file_name).write_text(f"Commit {commit_idx + 1} on {commit_date}")
                    subprocess.run(["git", "add", file_name])
                    
                    # Create commit with specified date
                    env = os.environ.copy()
                    env["GIT_AUTHOR_DATE"] = commit_date
                    env["GIT_COMMITTER_DATE"] = commit_date
                    subprocess.run(["git", "commit", "-m", f"Activity {commit_idx + 1} on {commit_date}"], env=env)
                    print(f"Created commit {commit_idx + 1} for {date_str}")

def build_pattern(name, column_spacing=1):
    """
    Build a GitHub activity pattern for a name
    
    Args:
        name: The name to display
        column_spacing: Number of empty columns between letters
    
    Returns:
        2D array representing the pattern
    """
    # Create a spacing column
    spacing = [[0] * column_spacing for _ in range(5)]
    
    # Initialize pattern with first letter
    pattern = letter_patterns[name[0].upper()]
    
    # Add remaining letters with spacing
    for letter in name[1:]:
        pattern = [row + spacing_row + letter_patterns[letter.upper()][i] 
                  for i, (row, spacing_row) in enumerate(zip(pattern, spacing))]
    
    return pattern

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) != 3:
        print("Usage: python github_activity_art.py <name> <start_date>")
        print("Example: python github_activity_art.py BLAINE 2025-05-11")
        sys.exit(1)
    
    name = sys.argv[1]
    start_date = datetime.datetime.strptime(sys.argv[2], "%Y-%m-%d")
    
    # Verify start date is a Sunday
    if start_date.weekday() != 6:
        print("Error: Start date must be a Sunday")
        sys.exit(1)
    
    pattern = build_pattern(name)
    create_commits_for_pattern(pattern, start_date)

    subprocess.run(["git", "remote", "add", "origin", "https://github.com/iblaine/say-my-name.git"])
    subprocess.run(["git", "push", "-u", "origin", "main"])
