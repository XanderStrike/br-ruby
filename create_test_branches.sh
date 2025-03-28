#!/bin/bash

# Function to create a commit with a specific date
create_dated_commit() {
    local branch=$1
    local message=$2
    local date=$3
    
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit --allow-empty -m "$message"
}

# Save current branch
current_branch=$(git branch --show-current)

# Create a temporary branch for test commits
git checkout -b temp_test_branch

# Create the base commit for all test branches
create_dated_commit "temp" "Base commit for test branches" "$(date -v-4m)"

# Create branches with commits at different times
# Branch 1 - minutes ago
git checkout -b feature/recent temp_test_branch
create_dated_commit "feature/recent" "Recent commit" "$(date -v-10M)"

# Branch 2 - hours ago
git checkout -b feature/today temp_test_branch
create_dated_commit "feature/today" "Today's commit" "$(date -v-5H)"

# Branch 3 - days ago
git checkout -b feature/week temp_test_branch
create_dated_commit "feature/week" "Last week's commit" "$(date -v-4d)"

# Branch 4 - weeks ago
git checkout -b feature/old temp_test_branch
create_dated_commit "feature/old" "Old commit" "$(date -v-3w)"

# Branch 5 - months ago
git checkout -b feature/ancient temp_test_branch
create_dated_commit "feature/ancient" "Ancient commit" "$(date -v-3m)"

# Return to original branch and clean up temp branch
git checkout "$current_branch"
git branch -D temp_test_branch

echo "Test branches created successfully!"
