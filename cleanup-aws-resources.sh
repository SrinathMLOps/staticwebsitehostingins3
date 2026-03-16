#!/bin/bash

# AWS Resource Cleanup Script
# This script deletes CloudFront, S3, and ACM resources for srinathkaithoju.com
# Regions: us-east-1 (N. Virginia) and eu-west-2 (London)

set -e  # Exit on error

echo "=========================================="
echo "AWS Resource Cleanup Script"
echo "Domain: srinathkaithoju.com"
echo "=========================================="
echo ""

# Variables
BUCKET_NAME="srinathkaithoju.com"
DOMAIN_NAME="srinathkaithoju.com"
LONDON_REGION="eu-west-2"
VIRGINIA_REGION="us-east-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  WARNING: This will delete all AWS resources for $DOMAIN_NAME${NC}"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "=========================================="
echo "Step 1: Finding and Disabling CloudFront Distribution"
echo "=========================================="

# Get CloudFront distribution ID
DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Aliases.Items, '$DOMAIN_NAME')].Id" --output text 2>/dev/null || echo "")

if [ -z "$DISTRIBUTION_ID" ]; then
    echo -e "${YELLOW}No CloudFront distribution found for $DOMAIN_NAME${NC}"
else
    echo -e "${GREEN}Found CloudFront distribution: $DISTRIBUTION_ID${NC}"
    
    # Get current distribution config
    echo "Getting distribution configuration..."
    ETAG=$(aws cloudfront get-distribution-config --id $DISTRIBUTION_ID --query 'ETag' --output text)
    
    # Get and modify config to disable
    aws cloudfront get-distribution-config --id $DISTRIBUTION_ID --query 'DistributionConfig' > /tmp/dist-config.json
    
    # Disable the distribution
    echo "Disabling CloudFront distribution..."
    jq '.Enabled = false' /tmp/dist-config.json > /tmp/dist-config-disabled.json
    
    aws cloudfront update-distribution \
        --id $DISTRIBUTION_ID \
        --distribution-config file:///tmp/dist-config-disabled.json \
        --if-match $ETAG > /dev/null
    
    echo -e "${GREEN}✓ CloudFront distribution disabled${NC}"
    echo -e "${YELLOW}⏳ Waiting for distribution to be fully disabled (this takes 5-15 minutes)...${NC}"
    
    # Wait for distribution to be disabled
    aws cloudfront wait distribution-deployed --id $DISTRIBUTION_ID
    
    echo "Deleting CloudFront distribution..."
    NEW_ETAG=$(aws cloudfront get-distribution-config --id $DISTRIBUTION_ID --query 'ETag' --output text)
    aws cloudfront delete-distribution --id $DISTRIBUTION_ID --if-match $NEW_ETAG
    
    echo -e "${GREEN}✓ CloudFront distribution deleted${NC}"
    
    # Cleanup temp files
    rm -f /tmp/dist-config.json /tmp/dist-config-disabled.json
fi

echo ""
echo "=========================================="
echo "Step 2: Emptying and Deleting S3 Bucket (London)"
echo "=========================================="

# Check if bucket exists
if aws s3api head-bucket --bucket $BUCKET_NAME --region $LONDON_REGION 2>/dev/null; then
    echo -e "${GREEN}Found S3 bucket: $BUCKET_NAME in $LONDON_REGION${NC}"
    
    # Empty the bucket
    echo "Emptying S3 bucket..."
    aws s3 rm s3://$BUCKET_NAME --recursive --region $LONDON_REGION
    
    # Delete all versions and delete markers (if versioning was enabled)
    echo "Removing all versions and delete markers..."
    aws s3api delete-objects --bucket $BUCKET_NAME --region $LONDON_REGION \
        --delete "$(aws s3api list-object-versions --bucket $BUCKET_NAME --region $LONDON_REGION \
        --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --max-items 1000)" 2>/dev/null || true
    
    aws s3api delete-objects --bucket $BUCKET_NAME --region $LONDON_REGION \
        --delete "$(aws s3api list-object-versions --bucket $BUCKET_NAME --region $LONDON_REGION \
        --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' --max-items 1000)" 2>/dev/null || true
    
    echo -e "${GREEN}✓ S3 bucket emptied${NC}"
    
    # Delete the bucket
    echo "Deleting S3 bucket..."
    aws s3api delete-bucket --bucket $BUCKET_NAME --region $LONDON_REGION
    
    echo -e "${GREEN}✓ S3 bucket deleted${NC}"
else
    echo -e "${YELLOW}No S3 bucket found: $BUCKET_NAME in $LONDON_REGION${NC}"
fi

echo ""
echo "=========================================="
echo "Step 3: Deleting SSL Certificate (N. Virginia)"
echo "=========================================="

# Get certificate ARN
CERT_ARN=$(aws acm list-certificates --region $VIRGINIA_REGION \
    --query "CertificateSummaryList[?DomainName=='$DOMAIN_NAME'].CertificateArn" \
    --output text 2>/dev/null || echo "")

if [ -z "$CERT_ARN" ]; then
    echo -e "${YELLOW}No SSL certificate found for $DOMAIN_NAME in $VIRGINIA_REGION${NC}"
else
    echo -e "${GREEN}Found SSL certificate: $CERT_ARN${NC}"
    
    echo "Deleting SSL certificate..."
    aws acm delete-certificate --certificate-arn $CERT_ARN --region $VIRGINIA_REGION
    
    echo -e "${GREEN}✓ SSL certificate deleted${NC}"
fi

echo ""
echo "=========================================="
echo "Step 4: Checking for Other Resources"
echo "=========================================="

# Check for any other S3 buckets in London
echo "Checking for other S3 buckets in $LONDON_REGION..."
OTHER_BUCKETS=$(aws s3api list-buckets --query "Buckets[?contains(Name, 'srinath')].Name" --output text 2>/dev/null || echo "")
if [ -n "$OTHER_BUCKETS" ]; then
    echo -e "${YELLOW}Found other buckets with 'srinath' in name:${NC}"
    echo "$OTHER_BUCKETS"
else
    echo -e "${GREEN}No other related buckets found${NC}"
fi

# Check for other certificates in Virginia
echo "Checking for other certificates in $VIRGINIA_REGION..."
OTHER_CERTS=$(aws acm list-certificates --region $VIRGINIA_REGION \
    --query "CertificateSummaryList[?contains(DomainName, 'srinath')].DomainName" \
    --output text 2>/dev/null || echo "")
if [ -n "$OTHER_CERTS" ]; then
    echo -e "${YELLOW}Found other certificates with 'srinath' in domain:${NC}"
    echo "$OTHER_CERTS"
else
    echo -e "${GREEN}No other related certificates found${NC}"
fi

# Check for CloudFront distributions
echo "Checking for other CloudFront distributions..."
OTHER_DISTS=$(aws cloudfront list-distributions \
    --query "DistributionList.Items[?contains(to_string(Aliases), 'srinath')].Id" \
    --output text 2>/dev/null || echo "")
if [ -n "$OTHER_DISTS" ]; then
    echo -e "${YELLOW}Found other CloudFront distributions:${NC}"
    echo "$OTHER_DISTS"
else
    echo -e "${GREEN}No other related distributions found${NC}"
fi

echo ""
echo "=========================================="
echo "✅ Cleanup Complete!"
echo "=========================================="
echo ""
echo "Resources deleted:"
echo "  ✓ CloudFront distribution (if found)"
echo "  ✓ S3 bucket: $BUCKET_NAME (London)"
echo "  ✓ SSL certificate (N. Virginia)"
echo ""
echo -e "${YELLOW}Note: DNS records are NOT deleted by this script.${NC}"
echo "You need to manually remove CNAME records from your domain registrar if needed."
echo ""
echo "To verify deletion, run:"
echo "  aws cloudfront list-distributions"
echo "  aws s3 ls --region $LONDON_REGION"
echo "  aws acm list-certificates --region $VIRGINIA_REGION"
echo ""
