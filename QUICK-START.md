# 🚀 Quick Start - Run Cleanup Script

## Step 1: Install AWS CLI

**Download and install AWS CLI:**
1. Download: https://awscli.amazonaws.com/AWSCLIV2.msi
2. Run the installer
3. Click "Next" through all steps
4. Restart your terminal/PowerShell after installation

**Verify installation:**
```powershell
aws --version
```
Should show: `aws-cli/2.x.x`

---

## Step 2: Configure AWS Credentials

**Get your AWS credentials:**
1. Log in to AWS Console: https://console.aws.amazon.com
2. Click your name (top right) → "Security credentials"
3. Scroll to "Access keys" section
4. Click "Create access key"
5. Copy both:
   - Access Key ID
   - Secret Access Key

**Configure AWS CLI:**
```powershell
aws configure
```

Enter when prompted:
```
AWS Access Key ID: [paste your access key]
AWS Secret Access Key: [paste your secret key]
Default region name: eu-west-2
Default output format: json
```

**Test configuration:**
```powershell
aws s3 ls
```
Should list your S3 buckets (or show empty)

---

## Step 3: Run the Cleanup Script

**You're already in the right folder!**

**Run the PowerShell script:**
```powershell
# Allow script execution (first time only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the cleanup script
.\cleanup-aws-resources.ps1
```

**When prompted:**
- Type: `yes`
- Press Enter

**Wait for completion:**
- Takes 10-20 minutes
- Don't close the window!

---

## Alternative: Manual Cleanup Commands

If you prefer to run commands manually:

```powershell
# 1. List what exists
aws cloudfront list-distributions
aws s3 ls
aws acm list-certificates --region us-east-1

# 2. Empty S3 bucket
aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2

# 3. Delete S3 bucket
aws s3api delete-bucket --bucket srinathkaithoju.com --region eu-west-2

# 4. List certificates to get ARN
aws acm list-certificates --region us-east-1

# 5. Delete certificate (replace with your ARN)
aws acm delete-certificate --certificate-arn arn:aws:acm:us-east-1:ACCOUNT:certificate/ID --region us-east-1
```

For CloudFront, you must disable it first (takes 10-15 minutes), then delete.

---

## Current Location

You're in: `C:\Users\SRINATH\Desktop\StaticWebsiteHostingwithS3`

All scripts are here and ready to run!

---

## Need Help?

1. **AWS CLI not found**: Install from link above, restart terminal
2. **Access Denied**: Run `aws configure` with your credentials
3. **Script won't run**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

---

## What the Script Will Delete

✅ CloudFront distribution (if exists)
✅ S3 bucket: srinathkaithoju.com (London region)
✅ SSL certificate (N. Virginia region)

⚠️ DNS records are NOT deleted - remove manually if needed
