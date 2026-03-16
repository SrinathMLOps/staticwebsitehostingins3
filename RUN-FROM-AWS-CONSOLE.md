# 🚀 Run Cleanup Script from AWS Console (CloudShell)

## Method 1: Using AWS CloudShell (Easiest!)

AWS CloudShell is a browser-based shell with AWS CLI pre-installed and pre-configured!

### Step 1: Open CloudShell

1. **Log in to AWS Console**: https://console.aws.amazon.com
2. **Click the CloudShell icon** (terminal icon) in the top-right corner, next to the search bar
   - Or search for "CloudShell" in the services search
3. **Wait for CloudShell to initialize** (takes 10-20 seconds)

### Step 2: Download the Cleanup Script

In CloudShell, run these commands:

```bash
# Download the cleanup script from your GitHub repo
curl -O https://raw.githubusercontent.com/SrinathMLOps/staticwebsitehostingins3/main/cleanup-aws-resources.sh

# Make it executable
chmod +x cleanup-aws-resources.sh

# Verify it downloaded
ls -la cleanup-aws-resources.sh
```

### Step 3: Run the Script

```bash
# Run the cleanup script
./cleanup-aws-resources.sh
```

**When prompted:**
- Type: `yes`
- Press Enter

**Wait for completion:**
- Takes 10-20 minutes
- CloudShell will show progress
- Don't close the browser tab!

---

## Method 2: Copy-Paste Commands (Manual)

If you prefer to run commands one by one in CloudShell:

### Step 1: Open CloudShell
(Same as above)

### Step 2: Run These Commands

```bash
# Set variables
BUCKET_NAME="srinathkaithoju.com"
LONDON_REGION="eu-west-2"
VIRGINIA_REGION="us-east-1"

echo "=========================================="
echo "Starting AWS Resource Cleanup"
echo "=========================================="

# 1. List CloudFront distributions
echo "Checking CloudFront distributions..."
aws cloudfront list-distributions --query "DistributionList.Items[?contains(Aliases.Items, '$BUCKET_NAME')].{Id:Id,Status:Status,Domain:DomainName}" --output table

# 2. Empty S3 bucket
echo "Emptying S3 bucket..."
aws s3 rm s3://$BUCKET_NAME --recursive --region $LONDON_REGION

# 3. Delete S3 bucket
echo "Deleting S3 bucket..."
aws s3api delete-bucket --bucket $BUCKET_NAME --region $LONDON_REGION

# 4. List certificates
echo "Checking SSL certificates..."
aws acm list-certificates --region $VIRGINIA_REGION --query "CertificateSummaryList[?DomainName=='$BUCKET_NAME'].{Domain:DomainName,ARN:CertificateArn,Status:Status}" --output table

echo "=========================================="
echo "Basic cleanup complete!"
echo "=========================================="
echo ""
echo "Note: CloudFront must be disabled manually first (takes 10-15 min)"
echo "Note: Certificate can only be deleted after CloudFront is removed"
```

### Step 3: Delete CloudFront (Manual)

CloudFront requires special handling:

```bash
# Get distribution ID
DIST_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Aliases.Items, 'srinathkaithoju.com')].Id" --output text)

if [ -n "$DIST_ID" ]; then
    echo "Found CloudFront distribution: $DIST_ID"
    echo "You need to:"
    echo "1. Go to CloudFront in AWS Console"
    echo "2. Select the distribution"
    echo "3. Click 'Disable'"
    echo "4. Wait 10-15 minutes"
    echo "5. Then click 'Delete'"
else
    echo "No CloudFront distribution found"
fi
```

### Step 4: Delete Certificate (After CloudFront is Gone)

```bash
# Get certificate ARN
CERT_ARN=$(aws acm list-certificates --region us-east-1 --query "CertificateSummaryList[?DomainName=='srinathkaithoju.com'].CertificateArn" --output text)

if [ -n "$CERT_ARN" ]; then
    echo "Deleting certificate: $CERT_ARN"
    aws acm delete-certificate --certificate-arn $CERT_ARN --region us-east-1
    echo "✓ Certificate deleted"
else
    echo "No certificate found"
fi
```

---

## Method 3: Using AWS Console UI (No Script)

If you prefer clicking through the console:

### Delete S3 Bucket
1. Go to **S3** service
2. Select bucket `srinathkaithoju.com`
3. Click **Empty** → Type `permanently delete` → Empty
4. Click **Delete** → Type bucket name → Delete

### Delete CloudFront
1. Go to **CloudFront** service
2. Select your distribution
3. Click **Disable** → Wait 10-15 minutes
4. Click **Delete** → Confirm

### Delete Certificate
1. Switch region to **US East (N. Virginia)** (top-right)
2. Go to **Certificate Manager**
3. Select your certificate
4. Click **Delete** → Confirm

---

## ✅ Advantages of CloudShell

- ✅ No installation needed
- ✅ AWS CLI pre-installed
- ✅ Already authenticated (uses your console login)
- ✅ No need to configure credentials
- ✅ Works from any browser
- ✅ Free to use

---

## 🎯 Quick Commands Reference

**Check what exists:**
```bash
# CloudFront
aws cloudfront list-distributions --output table

# S3 buckets
aws s3 ls

# Certificates (in us-east-1)
aws acm list-certificates --region us-east-1 --output table
```

**Delete S3 bucket:**
```bash
aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2
aws s3api delete-bucket --bucket srinathkaithoju.com --region eu-west-2
```

**Check specific bucket:**
```bash
aws s3 ls s3://srinathkaithoju.com --region eu-west-2
```

---

## 📊 What to Expect

**CloudShell Output:**
```
==========================================
Starting AWS Resource Cleanup
==========================================
Checking CloudFront distributions...
Found CloudFront distribution: E1234ABCD5678
Emptying S3 bucket...
delete: s3://srinathkaithoju.com/index.html
delete: s3://srinathkaithoju.com/css/style.css
...
Deleting S3 bucket...
✓ S3 bucket deleted
Checking SSL certificates...
Found certificate: arn:aws:acm:us-east-1:...
==========================================
Basic cleanup complete!
==========================================
```

---

## ⚠️ Important Notes

1. **CloudShell timeout**: Sessions timeout after 20 minutes of inactivity
2. **CloudFront takes time**: Disabling takes 10-15 minutes
3. **Certificate dependency**: Can only delete after CloudFront is removed
4. **No local installation**: Everything runs in AWS cloud
5. **Free tier**: CloudShell is included in AWS Free Tier

---

## 🔍 Verify Deletion

After running commands:

```bash
# Should return empty or no results
aws cloudfront list-distributions
aws s3 ls | grep srinath
aws acm list-certificates --region us-east-1
```

---

## 💡 Pro Tip

You can also upload the script file directly to CloudShell:
1. Click **Actions** → **Upload file**
2. Select `cleanup-aws-resources.sh`
3. Run: `chmod +x cleanup-aws-resources.sh && ./cleanup-aws-resources.sh`

---

**CloudShell is the easiest way - no installation, no configuration needed!** 🚀
