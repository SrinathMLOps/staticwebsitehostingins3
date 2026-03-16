# 🚀 How to Run Cleanup Script on Windows

## Step 1: Install AWS CLI (If Not Installed)

1. **Download AWS CLI**
   - Go to: https://awscli.amazonaws.com/AWSCLIV2.msi
   - Download and run the installer
   - Click "Next" through the installation

2. **Verify Installation**
   - Open Command Prompt or PowerShell
   - Type: `aws --version`
   - You should see something like: `aws-cli/2.x.x`

---

## Step 2: Configure AWS Credentials

1. **Get Your AWS Credentials**
   - Log in to AWS Console
   - Click your name (top right) → "Security credentials"
   - Scroll to "Access keys"
   - Click "Create access key"
   - Copy the Access Key ID and Secret Access Key

2. **Configure AWS CLI**
   - Open Command Prompt or PowerShell
   - Type: `aws configure`
   - Enter when prompted:
     ```
     AWS Access Key ID: [paste your key]
     AWS Secret Access Key: [paste your secret]
     Default region name: eu-west-2
     Default output format: json
     ```

3. **Test Configuration**
   ```bash
   aws s3 ls
   ```
   Should list your S3 buckets (or show empty if none exist)

---

## Step 3: Run the Cleanup Script

### Option A: Using PowerShell (Recommended for Windows)

1. **Open PowerShell**
   - Press `Windows + X`
   - Select "Windows PowerShell" or "Terminal"

2. **Navigate to Script Location**
   ```powershell
   cd path\to\your\script\folder
   ```
   Example: `cd C:\Users\YourName\Downloads`

3. **Allow Script Execution (First Time Only)**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
   Type `Y` and press Enter

4. **Run the Script**
   ```powershell
   .\cleanup-aws-resources.ps1
   ```

5. **Confirm Deletion**
   - Script will ask: "Are you sure you want to continue?"
   - Type: `yes`
   - Press Enter

6. **Wait for Completion**
   - Script will show progress
   - Takes 10-20 minutes total
   - Don't close the window!

---

### Option B: Using Git Bash (If You Have Git Installed)

1. **Open Git Bash**
   - Right-click in the folder with the script
   - Select "Git Bash Here"

2. **Make Script Executable**
   ```bash
   chmod +x cleanup-aws-resources.sh
   ```

3. **Run the Script**
   ```bash
   ./cleanup-aws-resources.sh
   ```

4. **Confirm Deletion**
   - Type: `yes`
   - Press Enter

---

### Option C: Using Command Prompt (CMD)

If PowerShell doesn't work, use Command Prompt:

1. **Open Command Prompt**
   - Press `Windows + R`
   - Type: `cmd`
   - Press Enter

2. **Navigate to Script Location**
   ```cmd
   cd path\to\your\script\folder
   ```

3. **Run AWS Commands Manually**
   ```cmd
   REM Step 1: List CloudFront distributions
   aws cloudfront list-distributions

   REM Step 2: Empty S3 bucket
   aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2

   REM Step 3: Delete S3 bucket
   aws s3api delete-bucket --bucket srinathkaithoju.com --region eu-west-2

   REM Step 4: List certificates
   aws acm list-certificates --region us-east-1
   ```

---

## Step 4: Verify Deletion

After script completes, verify everything is deleted:

```powershell
# Check CloudFront
aws cloudfront list-distributions

# Check S3 buckets
aws s3 ls --region eu-west-2

# Check certificates
aws acm list-certificates --region us-east-1
```

All should return empty or no results for srinathkaithoju.com

---

## 🎯 Quick Command Reference

### Check What Exists Before Deleting

```powershell
# List CloudFront distributions
aws cloudfront list-distributions --query "DistributionList.Items[].{Id:Id,Domain:DomainName,Aliases:Aliases.Items}" --output table

# List S3 buckets
aws s3 ls

# Check specific bucket
aws s3 ls s3://srinathkaithoju.com --region eu-west-2

# List certificates
aws acm list-certificates --region us-east-1 --output table
```

### Manual Deletion Commands

If script fails, use these commands:

```powershell
# 1. Empty S3 bucket
aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2

# 2. Delete S3 bucket
aws s3api delete-bucket --bucket srinathkaithoju.com --region eu-west-2

# 3. Delete certificate (replace ARN)
aws acm delete-certificate --certificate-arn arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT_ID --region us-east-1
```

For CloudFront, you must disable it first (takes 10-15 minutes), then delete.

---

## ⚠️ Troubleshooting

### Error: "aws: command not found"
- **Solution**: Install AWS CLI (see Step 1)
- Restart your terminal after installation

### Error: "Unable to locate credentials"
- **Solution**: Run `aws configure` (see Step 2)

### Error: "Access Denied"
- **Solution**: Check your AWS credentials have proper permissions
- You need admin access or CloudFront/S3/ACM permissions

### Error: "cannot be loaded because running scripts is disabled"
- **Solution**: Run this in PowerShell as Administrator:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

### Error: "Distribution must be disabled first"
- **Solution**: The script handles this automatically
- If manual: Wait 10-15 minutes after disabling before deleting

### Error: "The bucket you tried to delete is not empty"
- **Solution**: Run:
  ```powershell
  aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2
  ```
  Then try deleting again

---

## 📊 What to Expect

**Script Output:**
```
==========================================
AWS Resource Cleanup Script
Domain: srinathkaithoju.com
==========================================

⚠️  WARNING: This will delete all AWS resources for srinathkaithoju.com

Are you sure you want to continue? (type 'yes' to confirm): yes

==========================================
Step 1: Finding and Disabling CloudFront Distribution
==========================================
Found CloudFront distribution: E1234ABCD5678
Disabling CloudFront distribution...
✓ CloudFront distribution disabled
⏳ Waiting for distribution to be fully disabled (this takes 5-15 minutes)...
Deleting CloudFront distribution...
✓ CloudFront distribution deleted

==========================================
Step 2: Emptying and Deleting S3 Bucket (London)
==========================================
Found S3 bucket: srinathkaithoju.com in eu-west-2
Emptying S3 bucket...
✓ S3 bucket emptied
Deleting S3 bucket...
✓ S3 bucket deleted

==========================================
Step 3: Deleting SSL Certificate (N. Virginia)
==========================================
Found SSL certificate: arn:aws:acm:us-east-1:...
Deleting SSL certificate...
✓ SSL certificate deleted

==========================================
✅ Cleanup Complete!
==========================================
```

---

## 💡 Pro Tips

1. **Run in PowerShell** - It has better color support and error handling
2. **Don't close the window** - Script takes 10-20 minutes
3. **Check AWS Console** - Verify deletion in the web interface too
4. **Wait for CloudFront** - This is the slowest part (10-15 minutes)
5. **Save your credentials** - You might need them again

---

## 🎉 After Cleanup

Once script completes:
- ✅ All AWS resources deleted
- ✅ No more charges
- ✅ Domain still owned by you
- ⚠️ DNS records still exist (delete manually if needed)

Check AWS Billing dashboard after 24 hours to confirm no charges.

---

## Need Help?

If you get stuck:
1. Copy the error message
2. Check the Troubleshooting section above
3. Try manual deletion commands
4. Verify AWS CLI is installed: `aws --version`
5. Verify credentials: `aws s3 ls`
