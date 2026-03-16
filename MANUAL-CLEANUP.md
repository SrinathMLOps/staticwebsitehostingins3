# 🧹 Manual Cleanup - Step by Step

The automated script had an issue. Let's check and clean up manually.

## Step 1: Check What Resources Exist

Run this in CloudShell:

```bash
# Download the check script
curl -O https://raw.githubusercontent.com/SrinathMLOps/staticwebsitehostingins3/main/check-resources.sh
chmod +x check-resources.sh
./check-resources.sh
```

This will show you exactly what exists.

---

## Step 2: Manual Cleanup Commands

Based on what exists, run these commands:

### A. Delete S3 Bucket (if exists)

```bash
# Check if bucket exists
aws s3 ls s3://srinathkaithoju.com --region eu-west-2

# If it exists, empty it
aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2

# Then delete it
aws s3api delete-bucket --bucket srinathkaithoju.com --region eu-west-2

# Verify deletion
aws s3 ls | grep srinath
```

**Expected output:** No bucket found

---

### B. Delete CloudFront Distribution (if exists)

```bash
# List all distributions
aws cloudfront list-distributions --query "DistributionList.Items[].{Id:Id,Status:Status,Aliases:Aliases.Items}" --output table

# If you see a distribution, get its ID
DIST_ID="YOUR_DISTRIBUTION_ID"  # Replace with actual ID

# Get the ETag
ETAG=$(aws cloudfront get-distribution-config --id $DIST_ID --query 'ETag' --output text)

# Get config and save it
aws cloudfront get-distribution-config --id $DIST_ID --query 'DistributionConfig' > /tmp/dist-config.json

# Disable it (edit the JSON to set Enabled: false)
# This is complex - easier to do in console
```

**Easier way for CloudFront:**
1. Go to AWS Console → CloudFront
2. Select the distribution
3. Click "Disable"
4. Wait 10-15 minutes
5. Click "Delete"

---

### C. Delete SSL Certificate (if exists)

```bash
# List certificates in us-east-1
aws acm list-certificates --region us-east-1 --output table

# If you see a certificate for srinathkaithoju.com, get its ARN
CERT_ARN="arn:aws:acm:us-east-1:ACCOUNT:certificate/ID"  # Replace with actual ARN

# Delete it
aws acm delete-certificate --certificate-arn $CERT_ARN --region us-east-1

# Verify deletion
aws acm list-certificates --region us-east-1
```

**Expected output:** No certificates found

---

## Step 3: Verify Everything is Deleted

```bash
# Check CloudFront
aws cloudfront list-distributions --query "DistributionList.Items[].Id" --output text

# Check S3
aws s3 ls | grep srinath

# Check Certificates
aws acm list-certificates --region us-east-1 --query "CertificateSummaryList[?contains(DomainName, 'srinath')]" --output table
```

All should return empty or no results.

---

## Quick Delete Script (Simple Version)

If you just want to delete S3 and Certificate (no CloudFront):

```bash
#!/bin/bash

echo "Deleting S3 bucket..."
aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2 2>/dev/null || echo "Bucket not found or already empty"
aws s3api delete-bucket --bucket srinathkaithoju.com --region eu-west-2 2>/dev/null || echo "Bucket not found or already deleted"

echo "Checking for certificates..."
CERT_ARN=$(aws acm list-certificates --region us-east-1 --query "CertificateSummaryList[?DomainName=='srinathkaithoju.com'].CertificateArn" --output text)

if [ -n "$CERT_ARN" ]; then
    echo "Deleting certificate: $CERT_ARN"
    aws acm delete-certificate --certificate-arn $CERT_ARN --region us-east-1
    echo "✓ Certificate deleted"
else
    echo "✓ No certificate found"
fi

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Note: CloudFront must be deleted manually from console if it exists"
```

---

## What Went Wrong with the Script?

The script found "None" as a distribution ID, which caused an error. This happens when:
- No CloudFront distribution exists
- The query returned unexpected format
- Distribution was already deleted

**Solution:** Run the check script first to see what actually exists, then delete manually.

---

## Using AWS Console (Easiest!)

If commands are confusing, just use the AWS Console:

### 1. Delete S3 Bucket
- Go to **S3** service
- Find `srinathkaithoju.com`
- Click **Empty** → Confirm
- Click **Delete** → Confirm

### 2. Delete CloudFront
- Go to **CloudFront** service
- Select distribution (if any)
- Click **Disable** → Wait 10-15 min
- Click **Delete** → Confirm

### 3. Delete Certificate
- Switch to **US East (N. Virginia)** region
- Go to **Certificate Manager**
- Select certificate (if any)
- Click **Delete** → Confirm

---

## Summary

**If script fails:**
1. Run `check-resources.sh` to see what exists
2. Delete manually using commands above
3. Or use AWS Console (easier)

**Most likely scenario:**
- S3 bucket might exist → Delete it
- Certificate might exist → Delete it
- CloudFront probably doesn't exist → Nothing to do

---

## Need Help?

Run the check script first:
```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/staticwebsitehostingins3/main/check-resources.sh
chmod +x check-resources.sh
./check-resources.sh
```

This will tell you exactly what needs to be deleted!
