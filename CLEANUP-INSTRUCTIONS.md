# 🗑️ AWS Resource Cleanup Scripts

## Quick Start

I've created two scripts to delete all AWS resources:
- `cleanup-aws-resources.sh` - For Mac/Linux/Git Bash
- `cleanup-aws-resources.ps1` - For Windows PowerShell

Both scripts will delete:
- ✅ CloudFront distribution (global)
- ✅ S3 bucket in London (eu-west-2)
- ✅ SSL certificate in N. Virginia (us-east-1)

---

## Prerequisites

1. **Install AWS CLI**
   - Download from: https://aws.amazon.com/cli/
   - Verify: `aws --version`

2. **Configure AWS Credentials**
   ```bash
   aws configure
   ```
   Enter your:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region: `eu-west-2`
   - Output format: `json`

3. **Verify Access**
   ```bash
   aws s3 ls
   aws cloudfront list-distributions
   ```

---

## Usage

### For Mac/Linux/Git Bash:

```bash
# Make script executable
chmod +x cleanup-aws-resources.sh

# Run the script
./cleanup-aws-resources.sh
```

### For Windows PowerShell:

```powershell
# Allow script execution (run PowerShell as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the script
.\cleanup-aws-resources.ps1
```

---

## What the Script Does

1. **Finds CloudFront distribution** for srinathkaithoju.com
2. **Disables it** (required before deletion)
3. **Waits** for it to be fully disabled (5-15 minutes)
4. **Deletes CloudFront** distribution
5. **Empties S3 bucket** in London region
6. **Deletes S3 bucket**
7. **Deletes SSL certificate** in N. Virginia
8. **Checks for other resources** with similar names

---

## Safety Features

- ✅ Asks for confirmation before deleting
- ✅ Shows what it finds before deleting
- ✅ Handles errors gracefully
- ✅ Checks for related resources
- ✅ Provides colored output for clarity

---

## Manual Cleanup (If Scripts Don't Work)

### Step 1: Delete CloudFront
```bash
# List distributions
aws cloudfront list-distributions

# Get distribution ID, then disable it
aws cloudfront get-distribution-config --id YOUR_DIST_ID > dist.json
# Edit dist.json, set "Enabled": false
aws cloudfront update-distribution --id YOUR_DIST_ID --distribution-config file://dist.json --if-match ETAG

# Wait 10 minutes, then delete
aws cloudfront delete-distribution --id YOUR_DIST_ID --if-match NEW_ETAG
```

### Step 2: Delete S3 Bucket
```bash
# Empty bucket
aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2

# Delete bucket
aws s3api delete-bucket --bucket srinathkaithoju.com --region eu-west-2
```

### Step 3: Delete Certificate
```bash
# List certificates in us-east-1
aws acm list-certificates --region us-east-1

# Delete certificate
aws acm delete-certificate --certificate-arn YOUR_CERT_ARN --region us-east-1
```

---

## Verify Deletion

```bash
# Check CloudFront
aws cloudfront list-distributions

# Check S3
aws s3 ls --region eu-west-2

# Check Certificates
aws acm list-certificates --region us-east-1
```

---

## DNS Records

⚠️ **Scripts do NOT delete DNS records!**

Manually remove these from your domain registrar:
- CNAME: www → CloudFront
- CNAME: @ → CloudFront  
- CNAME: _acaa304dabe4d9f... → validation record

---

## Troubleshooting

### "Unable to locate credentials"
```bash
aws configure
# Enter your AWS credentials
```

### "Access Denied"
- Check your IAM permissions
- Make sure you have admin access or proper policies

### "Distribution must be disabled"
- Wait 10-15 minutes after disabling
- Check status: `aws cloudfront get-distribution --id YOUR_ID`

### "Bucket not empty"
- Run: `aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2`
- Then try deleting again

---

## Estimated Time

- CloudFront disable: 5-15 minutes
- CloudFront delete: 1 minute
- S3 empty & delete: 1-5 minutes
- Certificate delete: Instant

**Total: ~10-20 minutes**

---

## Cost After Deletion

Once all resources are deleted:
- ✅ No more CloudFront charges
- ✅ No more S3 storage charges
- ✅ No more data transfer charges

Check AWS Billing dashboard after 24 hours to confirm.
