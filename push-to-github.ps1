# Script to push all files to GitHub repository
# Repository: https://github.com/SrinathMLOps/staticwebsitehostingins3

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Pushing to GitHub Repository" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Initialize git if not already initialized
if (-not (Test-Path .git)) {
    Write-Host "Initializing git repository..."
    git init
    Write-Host "✓ Git initialized" -ForegroundColor Green
} else {
    Write-Host "✓ Git repository already initialized" -ForegroundColor Green
}

# Add remote if not already added
$remotes = git remote
if ($remotes -notcontains "origin") {
    Write-Host "Adding remote repository..."
    git remote add origin https://github.com/SrinathMLOps/staticwebsitehostingins3.git
    Write-Host "✓ Remote added" -ForegroundColor Green
} else {
    Write-Host "✓ Remote already exists" -ForegroundColor Green
    # Update remote URL to make sure it's correct
    git remote set-url origin https://github.com/SrinathMLOps/staticwebsitehostingins3.git
}

# Add all files
Write-Host ""
Write-Host "Adding files to git..."
git add .

# Show status
Write-Host ""
Write-Host "Files to be committed:"
git status --short

# Commit
Write-Host ""
$commit_msg = Read-Host "Enter commit message (or press Enter for default)"
if ([string]::IsNullOrWhiteSpace($commit_msg)) {
    $commit_msg = "Add AWS S3 static website hosting guide and automation scripts"
}

git commit -m $commit_msg
Write-Host "✓ Files committed" -ForegroundColor Green

# Push to GitHub
Write-Host ""
Write-Host "Pushing to GitHub..."
git branch -M main
git push -u origin main

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Repository: https://github.com/SrinathMLOps/staticwebsitehostingins3"
Write-Host ""
