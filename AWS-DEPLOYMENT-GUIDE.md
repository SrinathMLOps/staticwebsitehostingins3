# 🚀 Complete AWS Deployment Guide
## Hosting srinathkaithoju.com on S3 + CloudFront (London Region)

**This is your ONE complete guide - follow steps in order!**

---

## 📋 Prerequisites

Before you begin, ensure you have:
- ✅ An AWS account (create one at aws.amazon.com)
- ✅ Your domain name: srinathkaithoju.com
- ✅ Access to your domain registrar's DNS panel (Advanced DNS section)
- ✅ Your website files from GitHub: https://github.com/SrinathMLOps/myportfolio
- ✅ A file named `index.html` as your homepage

---

## 📦 What Files to Upload

Download your repository as ZIP from GitHub, extract it, and upload ALL these files to S3:

**✅ Upload:**
- All `.html` files (index.html, about.html, etc.)
- All `.css` files and css/ folder
- All `.js` files and js/ folder
- All image files (.png, .jpg, .svg, etc.) and images/ folder
- favicon.ico
- Any other website assets

**❌ Don't Upload:**
- .git/ folder
- .gitignore file
- README.md
- .vscode/ folder

**Important:** Upload the CONTENTS of your extracted folder, not the parent folder itself. Files should be at the root level of the S3 bucket, not inside a subfolder.

---

## Step 1: Create S3 Bucket 🪣

1. **Log in to AWS Console**
   - Go to https://console.aws.amazon.com
   - Sign in with your credentials

2. **Navigate to S3**
   - Click on "Services" in the top menu
   - Search for "S3" or find it under "Storage"
   - Click on "S3"

3. **Create New Bucket**
   - Click the orange "Create bucket" button
   
4. **Configure Bucket Settings**
   - **Bucket name**: `srinathkaithoju.com` (must match your domain exactly)
   - **AWS Region**: Select `Europe (London) eu-west-2`
   
5. **Configure Public Access**
   - Scroll to "Block Public Access settings for this bucket"
   - **UNCHECK** "Block all public access"
   - Check the acknowledgement box that appears
   - ⚠️ This is required for website hosting

6. **Leave Other Settings as Default**
   - Bucket Versioning: Disabled
   - Tags: Optional
   - Default encryption: Enabled (default)
   - Object Lock: Disabled

7. **Create the Bucket**
   - Scroll to the bottom
   - Click "Create bucket"
   - ✅ You should see a success message

---

## Step 2: Upload Your Website Files 📤

1. **Download Your Repository**
   - Go to: https://github.com/SrinathMLOps/myportfolio
   - Click green "Code" button → "Download ZIP"
   - Extract the ZIP file
   - Open the extracted folder until you see `index.html`

2. **Open Your Bucket**
   - Click on your newly created bucket `srinathkaithoju.com`

3. **Upload Files**
   - Click the "Upload" button
   - Drag and drop ALL files and folders from the extracted folder
   - **CRITICAL:** Upload the contents, not the parent folder
   - Files should be at bucket root level, not inside a subfolder

4. **Complete Upload**
   - Scroll down and click "Upload"
   - Wait for all files to finish uploading (should be 30-40 files)
   - Click "Close" when done

5. **Verify Upload**
   - ✅ You should see `index.html` at the root level (not inside a folder)
   - ✅ You should see folders like css/, js/, images/ at root level
   - ❌ If you see a folder like "myportfolio-main/" containing everything, you uploaded wrong - delete it and re-upload the contents

---

## Step 3: Add Bucket Policy (Make It Public) 🔓

1. **Go to Permissions Tab**
   - In your bucket, click the "Permissions" tab

2. **Edit Bucket Policy**
   - Scroll down to "Bucket policy" section
   - Click "Edit"

3. **Paste This Policy**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "PublicReadGetObject",
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::srinathkaithoju.com/*"
       }
     ]
   }
   ```

4. **Save Changes**
   - Click "Save changes"
   - ✅ You should see "Successfully edited bucket policy"

---

## Step 4: Enable Static Website Hosting 🌐

1. **Go to Properties Tab**
   - In your bucket, click the "Properties" tab

2. **Find Static Website Hosting**
   - Scroll all the way down to "Static website hosting"
   - Click "Edit"

3. **Configure Settings**
   - **Static website hosting**: Select "Enable"
   - **Hosting type**: Select "Host a static website"
   - **Index document**: Enter `index.html`
   - **Error document**: Enter `index.html` (or `404.html` if you have one)

4. **Save Changes**
   - Click "Save changes"

5. **Note Your Endpoint**
   - Scroll back down to "Static website hosting"
   - Copy the "Bucket website endpoint" URL
   - It will look like: `http://srinathkaithoju.com.s3-website.eu-west-2.amazonaws.com`
   - ✅ Test this URL in your browser - your site should load!

---

## Step 5: Request SSL Certificate (ACM) 🔒

⚠️ **IMPORTANT**: SSL certificates for CloudFront MUST be created in the `us-east-1` region!

**Your certificate will show "Pending validation" - you'll validate it in Step 5B below.**

1. **Switch to US East (N. Virginia) Region**
   - In the top-right corner of AWS Console
   - Click on the region dropdown (currently showing "London")
   - Select "US East (N. Virginia) us-east-1"

2. **Navigate to Certificate Manager**
   - Click "Services"
   - Search for "Certificate Manager" or "ACM"
   - Click on "AWS Certificate Manager"

3. **Request a Certificate**
   - Click "Request a certificate"
   - Select "Request a public certificate"
   - Click "Next"

4. **Add Domain Names**
   - **Domain name 1**: `srinathkaithoju.com`
   - Click "Add another name to this certificate"
   - **Domain name 2**: `*.srinathkaithoju.com` (wildcard for subdomains)
   - This covers both www and non-www versions

5. **Select Validation Method**
   - Choose "DNS validation - recommended"
   - Click "Next"

6. **Add Tags (Optional)**
   - You can skip this or add tags like:
     - Key: `Name`, Value: `srinathkaithoju.com`
   - Click "Next"

7. **Review and Request**
   - Review your settings
   - Click "Request"

8. **Validate Your Domain**
   - Click "View certificate"
   - Under "Domains", you'll see CNAME records
   - Click "Create records in Route 53" (if using Route 53)
   - **OR** manually add the CNAME records to your domain registrar:
     - Copy the "CNAME name" and "CNAME value"
     - Go to your domain registrar (GoDaddy, Namecheap, etc.)
     - Add a new CNAME record with these values
     - Repeat for both domain entries

9. **Certificate Status**
   - Status will show "Pending validation"
   - ⚠️ **Don't wait here - proceed to Step 5B to validate it**

---

## Step 5B: Validate SSL Certificate (CRITICAL!) 🔐

Your certificate needs DNS validation before it can be used.

1. **In AWS Certificate Manager**
   - Click on your certificate
   - Under "Domains" section, you'll see CNAME records for validation
   - You should see 2 domains with CNAME name and CNAME value

2. **Copy the Validation CNAME**
   - Look for something like:
     - CNAME Name: `_acaa304dabe4d9f14c95a3667a85c08.srinathkaithoju.com`
     - CNAME Value: `_6E7f4375ac8d01b3f8c9fe2a2639c9965.acktzcszr.validations.aws`
   - Copy both values (you'll need them for DNS)

3. **Go to Your Domain Registrar's DNS Panel**
   - Log in to where you manage your domain
   - Go to "Advanced DNS" or "DNS Management" section
   - You should see existing DNS records

4. **Add Validation CNAME Record**
   - Click "Add New Record" or "Actions" → "Add Record"
   - Fill in:
     - **Type**: `CNAME Record`
     - **Host**: Paste the CNAME Name (remove your domain from the end)
       - Example: If it shows `_acaa304dabe4d9f14c95a3667a85c08.srinathkaithoju.com`
       - Just use: `_acaa304dabe4d9f14c95a3667a85c08`
     - **Value**: Paste the full CNAME Value
       - Example: `_6E7f4375ac8d01b3f8c9fe2a2639c9965.acktzcszr.validations.aws`
     - **TTL**: `Automatic` or `3600`
   - Click "Save" or checkmark ✓

5. **Wait for Certificate Validation**
   - Go back to AWS Certificate Manager
   - Refresh the page every few minutes
   - Status will change from "Pending validation" to "Issued"
   - This usually takes 5-30 minutes
   - ✅ **WAIT until status shows "Issued" before proceeding to Step 6!**

---

## Step 6: Create CloudFront Distribution ⚡

⚠️ **Only proceed after your SSL certificate shows "Issued" status!**

1. **Navigate to CloudFront**
   - Click "Services"
   - Search for "CloudFront"
   - Click on "CloudFront"

2. **Create Distribution**
   - Click "Create distribution"

3. **Configure Origin Settings**
   - **Origin domain**: Click the dropdown and select your S3 bucket
     - It should show: `srinathkaithoju.com.s3.eu-west-2.amazonaws.com`
   - **Name**: Auto-filled (leave as is)
   - **Origin access**: Select "Origin access control settings (recommended)"
   - Click "Create new OAC"
     - Name: `srinathkaithoju.com-OAC` (or leave default)
     - Click "Create"

4. **Configure Default Cache Behavior**
   - **Viewer protocol policy**: Select "Redirect HTTP to HTTPS"
   - **Allowed HTTP methods**: GET, HEAD (default)
   - **Cache policy**: CachingOptimized (default)
   - Leave other settings as default

5. **Configure Distribution Settings**
   - **Price class**: Use all edge locations (best performance)
   - **Alternate domain names (CNAMEs)**: Click "Add item"
     - Add: `srinathkaithoju.com`
     - Click "Add item" again
     - Add: `www.srinathkaithoju.com`
   
   - **Custom SSL certificate**: Click the dropdown
     - Select your certificate: `srinathkaithoju.com`
     - (If you don't see it, make sure you created it in us-east-1)
   
   - **Default root object**: Enter `index.html`

6. **Create Distribution**
   - Scroll to the bottom
   - Click "Create distribution"
   - ⏳ Deployment takes 5-15 minutes

7. **Update S3 Bucket Policy for OAC**
   - You'll see a blue banner saying "The S3 bucket policy needs to be updated"
   - Click "Copy policy"
   - Go back to S3 → Your bucket → Permissions → Bucket policy
   - Click "Edit"
   - Replace the existing policy with the copied policy
   - Click "Save changes"

8. **Note Your CloudFront Domain**
   - Copy the "Distribution domain name"
   - It will look like: `d1234abcd5678.cloudfront.net`
   - ✅ Wait for Status to change from "Deploying" to "Enabled"

---

## Step 7: Update DNS Records 🌍

Now point your domain to CloudFront:

1. **Get Your CloudFront Domain**
   - Go to CloudFront → Your distribution
   - Copy the "Distribution domain name" (e.g., `d1234abcd5678.cloudfront.net`)

2. **Go to Your Domain Registrar's DNS Panel**
   - Log in to your domain registrar
   - Go to "Advanced DNS" or "DNS Management"

3. **Delete Old Records (if any)**
   - If you have existing CNAME: `www` → `srinathmlops.github.io` - delete it (click trash icon 🗑️)
   - If you have A Records pointing to GitHub Pages (185.199.x.x IPs) - delete them
   - If you have other records for @ or www - delete them

4. **Add New CNAME Records**

   **Record 1 (for www.srinathkaithoju.com):**
   - Type: `CNAME Record`
   - Host: `www`
   - Value: `d1234abcd5678.cloudfront.net` (your CloudFront domain)
   - TTL: `Automatic`

   **Record 2 (for srinathkaithoju.com):**
   - Type: `CNAME Record`
   - Host: `@`
   - Value: `d1234abcd5678.cloudfront.net` (same CloudFront domain)
   - TTL: `Automatic`

5. **Save All Changes**
   - Click "Save" or "Apply Changes"
   - ⏳ DNS propagation takes 10-60 minutes (sometimes up to 48 hours)

---

## Step 8: Test Your Website ✅

1. **Wait for DNS Propagation**
   - Check status at: https://dnschecker.org
   - Enter your domain: `srinathkaithoju.com`

2. **Test Your URLs**
   - `https://srinathkaithoju.com` ✅
   - `https://www.srinathkaithoju.com` ✅
   - Both should load with HTTPS (green padlock)

3. **Verify CloudFront is Working**
   - Open browser developer tools (F12)
   - Go to Network tab
   - Reload your site
   - Check response headers for `x-cache: Hit from cloudfront`

---

## 🎉 Congratulations!

Your website is now live on AWS with:
- ⚡ Global CDN (CloudFront)
- 🔒 HTTPS encryption
- 🪣 Scalable storage (S3)
- 🌍 Fast worldwide access
- 💰 Cost-effective hosting

---

## 📊 Summary of Your URLs

| Access Method | URL |
|--------------|-----|
| **Live Website** | https://srinathkaithoju.com |
| **WWW Version** | https://www.srinathkaithoju.com |
| **CloudFront Domain** | https://d1234abcd5678.cloudfront.net |
| **S3 Endpoint** (testing only) | http://srinathkaithoju.com.s3-website.eu-west-2.amazonaws.com |

---

## 🔧 Troubleshooting

### Issue: 404 Not Found - Key: index.html
- **Problem**: S3 can't find your index.html file
- **Solution**: 
  - Go to S3 bucket
  - Check if `index.html` is at root level (not inside a folder)
  - If files are in a subfolder like "myportfolio-main/", move them to root
  - Delete the empty folder
  - Test S3 endpoint URL again

### Issue: Certificate not showing in CloudFront
- **Solution**: Make sure you created the certificate in `us-east-1` region, not London

### Issue: Certificate stuck on "Pending validation"
- **Solution**: 
  - Check you added the validation CNAME record to your DNS
  - Make sure you copied the CNAME values correctly
  - Wait 30 minutes and refresh
  - Check DNS propagation at dnschecker.org

### Issue: 403 Forbidden error
- **Solution**: Check bucket policy is correct and bucket is not blocking public access

### Issue: DNS not resolving
- **Solution**: Wait longer (up to 48 hours) or check DNS records are correct

### Issue: CloudFront shows S3 XML error
- **Solution**: Make sure "Default root object" is set to `index.html` in CloudFront

### Issue: HTTP works but HTTPS doesn't
- **Solution**: Verify SSL certificate is validated and attached to CloudFront distribution

### Issue: "CNAME already exists" error in DNS
- **Solution**: Delete the old CNAME record first, then add the new one

---

## 💡 Next Steps

- Set up CloudFront invalidations for cache clearing
- Enable CloudFront access logs
- Set up AWS CloudWatch alarms
- Configure custom error pages
- Add CloudFront Functions for redirects
- Set up CI/CD pipeline for automatic deployments

---

## 📞 Need Help?

- AWS Documentation: https://docs.aws.amazon.com
- AWS Support: https://console.aws.amazon.com/support
- Community Forums: https://repost.aws

---

**Region Summary:**
- 🪣 S3 Bucket: `eu-west-2` (London)
- ⚡ CloudFront: Global (all edge locations)
- 🔒 ACM Certificate: `us-east-1` (N. Virginia) - Required for CloudFront

---

## 📝 Step-by-Step Checklist

Use this to track your progress:

- [ ] Step 1: S3 bucket created (name: srinathkaithoju.com, region: eu-west-2)
- [ ] Step 2: Website files uploaded (index.html at root level)
- [ ] Step 3: Bucket policy added (public read access)
- [ ] Step 4: Static website hosting enabled (tested endpoint URL)
- [ ] Step 5: SSL certificate requested (in us-east-1 region)
- [ ] Step 5B: Validation CNAME added to DNS (certificate shows "Issued")
- [ ] Step 6: CloudFront distribution created (status: "Enabled")
- [ ] Step 6: S3 bucket policy updated for OAC
- [ ] Step 7: DNS CNAME records added (www and @)
- [ ] Step 8: Tested https://srinathkaithoju.com (works!)
- [ ] Step 8: Tested https://www.srinathkaithoju.com (works!)

---

## 🎯 Quick Reference: Your DNS Records

After completing all steps, your DNS should have these records:

| Type | Host | Value | Purpose |
|------|------|-------|---------|
| CNAME | `_acaa304dabe4d9f...` | `_6E7f4375ac8d01b3f...` | SSL validation (keep it) |
| CNAME | `www` | `d1234abcd5678.cloudfront.net` | WWW subdomain |
| CNAME | `@` | `d1234abcd5678.cloudfront.net` | Root domain |

(Replace CloudFront domain with your actual one)

---

## 💰 Cost Estimate

For a portfolio site with moderate traffic:
- S3 Storage (5-50 MB): ~$0.10-0.50/month
- S3 Requests: ~$0.01-0.10/month
- CloudFront (1-10 GB transfer): ~$1-5/month
- SSL Certificate: FREE
- **Total: ~$2-6/month**

First 12 months may be cheaper with AWS Free Tier!

---

## 🔄 How to Update Your Site Later

When you make changes to your website:

1. **Upload new files to S3:**
   - Go to S3 → Your bucket
   - Upload changed files (they'll overwrite old ones)

2. **Clear CloudFront cache:**
   - Go to CloudFront → Your distribution
   - Click "Invalidations" tab
   - Click "Create invalidation"
   - Path: `/*` (clears everything)
   - Click "Create invalidation"
   - Wait 2-5 minutes

3. **Test your site:**
   - Open in incognito mode
   - Your changes should be visible

---

**This is your complete guide - everything you need is here! Follow the steps in order and you'll have your site live on AWS.** 🚀

---

## 🗑️ How to Delete AWS Resources (Cleanup)

If you want to remove everything and stop charges:

### Step 1: Delete CloudFront Distribution

1. **Go to CloudFront**
   - AWS Console → CloudFront

2. **Disable the Distribution First**
   - Select your distribution (checkbox)
   - Click "Disable"
   - Wait 5-10 minutes for status to change to "Disabled"

3. **Delete the Distribution**
   - Select the disabled distribution
   - Click "Delete"
   - Confirm deletion

⚠️ **You must disable before you can delete!**

---

### Step 2: Delete S3 Bucket

1. **Go to S3**
   - AWS Console → S3

2. **Empty the Bucket First**
   - Click on your bucket `srinathkaithoju.com`
   - Click "Empty" button
   - Type `permanently delete` to confirm
   - Click "Empty"
   - Wait for all files to be deleted

3. **Delete the Bucket**
   - Go back to S3 buckets list
   - Select your bucket (checkbox)
   - Click "Delete"
   - Type the bucket name to confirm
   - Click "Delete bucket"

⚠️ **You must empty the bucket before you can delete it!**

---

### Step 3: Delete SSL Certificate

1. **Go to Certificate Manager**
   - AWS Console → Certificate Manager
   - **Make sure you're in us-east-1 region!**

2. **Delete Certificate**
   - Select your certificate
   - Click "Delete"
   - Confirm deletion

⚠️ **You can only delete the certificate after CloudFront is deleted!**

---

### Step 4: Remove DNS Records (Optional)

If you want to stop pointing your domain to AWS:

1. **Go to Your Domain Registrar's DNS Panel**
   - Log in to your domain registrar
   - Go to "Advanced DNS" section

2. **Delete CNAME Records**
   - Delete CNAME: `www` → CloudFront
   - Delete CNAME: `@` → CloudFront
   - Delete CNAME: `_acaa304dabe4d9f...` (validation record)

3. **Save Changes**

---

## 🔄 Deletion Order (Important!)

**You MUST delete in this order:**

```
1. CloudFront Distribution (disable first, then delete)
   ↓ Wait for deletion to complete
2. S3 Bucket (empty first, then delete)
   ↓ Wait for deletion to complete
3. SSL Certificate
   ↓
4. DNS Records (optional)
```

**Why this order?**
- CloudFront must be deleted before you can delete the SSL certificate
- S3 bucket must be empty before you can delete it
- CloudFront must be deleted before you can delete the S3 bucket (if OAC is configured)

---

## ⏱️ Deletion Timeline

| Resource | Time to Disable/Empty | Time to Delete |
|----------|----------------------|----------------|
| CloudFront | 5-10 minutes | 5-10 minutes |
| S3 Bucket | 1-5 minutes | Instant |
| SSL Certificate | N/A | Instant |
| DNS Records | N/A | Instant |

**Total time: ~15-30 minutes**

---

## 💰 Stop Charges Immediately

To stop AWS charges right away:

1. **Disable CloudFront** - stops CDN charges
2. **Empty S3 bucket** - stops storage charges
3. **Delete everything** - ensures no future charges

Even if you don't delete resources, disabling CloudFront and emptying S3 will stop most charges.

---

## 🔍 Verify Everything is Deleted

After deletion, check:

- [ ] CloudFront: No distributions listed
- [ ] S3: Bucket `srinathkaithoju.com` not found
- [ ] Certificate Manager (us-east-1): No certificates listed
- [ ] Your domain: No longer resolves to AWS (may take time for DNS to update)

---

## ⚠️ Common Deletion Errors

### "Cannot delete distribution - must be disabled first"
- **Solution**: Disable the distribution, wait 10 minutes, then delete

### "Cannot delete bucket - bucket not empty"
- **Solution**: Click "Empty" button first, then delete

### "Cannot delete certificate - in use by CloudFront"
- **Solution**: Delete CloudFront distribution first, then delete certificate

### "Access Denied when deleting"
- **Solution**: Make sure you have proper IAM permissions

---

## 🎯 Quick Cleanup Checklist

Use this to track your cleanup:

- [ ] CloudFront distribution disabled
- [ ] Waited 10 minutes
- [ ] CloudFront distribution deleted
- [ ] S3 bucket emptied
- [ ] S3 bucket deleted
- [ ] SSL certificate deleted
- [ ] DNS CNAME records removed (optional)
- [ ] Verified no resources remain
- [ ] Checked AWS billing to confirm no charges

---

**Need to rebuild later?** Just follow the deployment guide again from Step 1! 🚀
