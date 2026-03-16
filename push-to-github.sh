#!/bin/bash

# Script to push all files to GitHub repository
# Repository: https://github.com/SrinathMLOps/staticwebsitehostingins3

echo "=========================================="
echo "Pushing to GitHub Repository"
echo "=========================================="
echo ""

# Initialize git if not already initialized
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
    echo "✓ Git initialized"
else
    echo "✓ Git repository already initialized"
fi

# Add remote if not already added
if ! git remote | grep -q origin; then
    echo "Adding remote repository..."
    git remote add origin https://github.com/SrinathMLOps/staticwebsitehostingins3.git
    echo "✓ Remote added"
else
    echo "✓ Remote already exists"
    # Update remote URL to make sure it's correct
    git remote set-url origin https://github.com/SrinathMLOps/staticwebsitehostingins3.git
fi

# Add all files
echo ""
echo "Adding files to git..."
git add .

# Show status
echo ""
echo "Files to be committed:"
git status --short

# Commit
echo ""
read -p "Enter commit message (or press Enter for default): " commit_msg
if [ -z "$commit_msg" ]; then
    commit_msg="Add AWS S3 static website hosting guide and automation scripts"
fi

git commit -m "$commit_msg"
echo "✓ Files committed"

# Push to GitHub
echo ""
echo "Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "=========================================="
echo "✅ Successfully pushed to GitHub!"
echo "=========================================="
echo ""
echo "Repository: https://github.com/SrinathMLOps/staticwebsitehostingins3"
echo ""
