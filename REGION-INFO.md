# 🌍 AWS Regions - Where to Run the Cleanup Script

## Important: Script Handles Both Regions Automatically!

You only need to run the script ONCE from ANY region. The script will automatically clean up resources in BOTH regions:

- 🪣 **London (eu-west-2)**: S3 bucket
- 🔒 **N. Virginia (us-east-1)**: SSL certificate
- ⚡ **Global**: CloudFront distribution

---

## Where to Run the Script?

### Option 1: Run from CloudShell (Any Region)

**You can run from ANY region - it doesn't matter!**

1. Open CloudShell from AWS Console (any region)
2. The script will automatically target:
   - `eu-west-2` for S3 bucket
   - `us-east-1` for SSL certificate
   - Global for CloudFront

```bash
# Download and run (works from any region)
curl -O https://raw.githubusercontent.com/SrinathMLOps/staticwebsitehostingins3/main/cleanup-aws-resources.sh
chmod +x cleanup-aws-resources.sh
./cleanup-aws-resources.sh
```

---

## What the Script Does in Each Region

### 1. Global (CloudFront)
```bash
# CloudFront is global - no region needed
aws cloudfront list-distributions
aws cloudfront delete-distribution --id DIST_ID
```

### 2. London Region (eu-west-2)
```bash
# S3 bucket in London
aws s3 rm s3://srinathkaithoju.com --recursive --region eu-west-2
aws s3api delete-bucket --bucket srinathkaithoju.com --region eu-west-2
```

### 3. N. Virginia Region (us-east-1)
```bash
# SSL certificate in N. Virginia
aws acm delete-certificate --certificate-arn ARN --region us-east-1
```

---

## Manual Cleanup (If You Prefer)

If you want to run commands manually in each region:

### Step 1: Clean London Region (eu-west-2)

**Open CloudShell and run:**
```bash
# Set region
export AWS_DEFAULT_REGION=eu-west-2

# Empty and delete S3 bucket
aws s3 rm s3://srinathkaithoju.com --recursive
aws s3api delete-bucket --bucket srinathkaithoju.com

echo "✓ London region cleaned"
```

### Step 2: Clean N. Virginia Region (us-east-1)

**Switch region and run:**
```bash
# Set region
export AWS_DEFAULT_REGION=us-east-1

# List and delete certificate
aws acm list-certificates
aws acm delete-certificate --certificate-arn YOUR_CERT_ARN

echo "✓ N. Virginia region cleaned"
```

### Step 3: Clean CloudFront (Global)

**Run from any region:**
```bash
# CloudFront is global
aws cloudfront list-distributions

# Get distribution ID and delete
# (Must disable first, then wait 10-15 minutes)
```

---

## Recommended Approach

**Just run the script once from CloudShell:**

```bash
# This ONE command cleans BOTH regions + CloudFront
./cleanup-aws-resources.sh
```

The script automatically:
1. ✅ Finds CloudFront distribution (global)
2. ✅ Disables and deletes CloudFront
3. ✅ Empties S3 bucket in London (eu-west-2)
4. ✅ Deletes S3 bucket in London
5. ✅ Deletes certificate in N. Virginia (us-east-1)

---

## Region Selection in CloudShell

When you open CloudShell, you might see a region selector. **It doesn't matter which region you choose** because:

- The script specifies `--region eu-west-2` for S3 commands
- The script specifies `--region us-east-1` for ACM commands
- CloudFront commands don't need a region (global service)

---

## Quick Reference

| Resource | Region | Command Flag |
|----------|--------|--------------|
| S3 Bucket | eu-west-2 (London) | `--region eu-west-2` |
| SSL Certificate | us-east-1 (N. Virginia) | `--region us-east-1` |
| CloudFront | Global | No region flag |

---

## Verify Cleanup in Both Regions

After running the script:

```bash
# Check London region
aws s3 ls --region eu-west-2 | grep srinath

# Check N. Virginia region
aws acm list-certificates --region us-east-1

# Check CloudFront (global)
aws cloudfront list-distributions
```

All should return empty or no results.

---

## 🎯 Summary

**Question**: Which region should I run the script in?

**Answer**: ANY region! The script handles both regions automatically.

**Easiest way**:
1. Open CloudShell (any region)
2. Run the script once
3. It cleans both regions + CloudFront

**No need to**:
- ❌ Switch regions manually
- ❌ Run script twice
- ❌ Run separate commands per region

**The script does it all!** 🚀
