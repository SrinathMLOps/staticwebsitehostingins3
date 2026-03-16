#!/bin/bash

# Script to check what AWS resources exist
# Run this in CloudShell to see what needs to be deleted

echo "=========================================="
echo "Checking AWS Resources"
echo "=========================================="
echo ""

BUCKET_NAME="srinathkaithoju.com"
LONDON_REGION="eu-west-2"
VIRGINIA_REGION="us-east-1"

# Check CloudFront
echo "1. Checking CloudFront Distributions..."
echo "----------------------------------------"
DISTRIBUTIONS=$(aws cloudfront list-distributions --query "DistributionList.Items[].{Id:Id,Status:Status,Aliases:Aliases.Items}" --output json 2>/dev/null)

if [ "$DISTRIBUTIONS" = "null" ] || [ -z "$DISTRIBUTIONS" ] || [ "$DISTRIBUTIONS" = "[]" ]; then
    echo "✓ No CloudFront distributions found"
else
    echo "Found CloudFront distributions:"
    aws cloudfront list-distributions --query "DistributionList.Items[].{Id:Id,Status:Status,Domain:DomainName,Aliases:Aliases.Items}" --output table
fi

echo ""

# Check S3 buckets
echo "2. Checking S3 Buckets in London (eu-west-2)..."
echo "----------------------------------------"
if aws s3api head-bucket --bucket $BUCKET_NAME --region $LONDON_REGION 2>/dev/null; then
    echo "✗ Found S3 bucket: $BUCKET_NAME"
    echo "  Checking contents..."
    OBJECT_COUNT=$(aws s3 ls s3://$BUCKET_NAME --region $LONDON_REGION --recursive 2>/dev/null | wc -l)
    echo "  Objects in bucket: $OBJECT_COUNT"
else
    echo "✓ No S3 bucket found: $BUCKET_NAME"
fi

echo ""

# Check all S3 buckets with 'srinath' in name
echo "3. Checking All S3 Buckets with 'srinath'..."
echo "----------------------------------------"
ALL_BUCKETS=$(aws s3 ls 2>/dev/null | grep -i srinath || echo "")
if [ -z "$ALL_BUCKETS" ]; then
    echo "✓ No buckets with 'srinath' in name"
else
    echo "Found buckets:"
    echo "$ALL_BUCKETS"
fi

echo ""

# Check SSL certificates
echo "4. Checking SSL Certificates in N. Virginia (us-east-1)..."
echo "----------------------------------------"
CERTS=$(aws acm list-certificates --region $VIRGINIA_REGION --query "CertificateSummaryList[?contains(DomainName, 'srinath')]" --output json 2>/dev/null)

if [ "$CERTS" = "[]" ] || [ -z "$CERTS" ]; then
    echo "✓ No SSL certificates found with 'srinath' in domain"
else
    echo "Found SSL certificates:"
    aws acm list-certificates --region $VIRGINIA_REGION --query "CertificateSummaryList[?contains(DomainName, 'srinath')].{Domain:DomainName,Status:Status,ARN:CertificateArn}" --output table
fi

echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""

HAS_RESOURCES=false

# Check each resource
if [ "$DISTRIBUTIONS" != "null" ] && [ "$DISTRIBUTIONS" != "[]" ] && [ -n "$DISTRIBUTIONS" ]; then
    echo "✗ CloudFront distributions exist - need to delete"
    HAS_RESOURCES=true
fi

if aws s3api head-bucket --bucket $BUCKET_NAME --region $LONDON_REGION 2>/dev/null; then
    echo "✗ S3 bucket exists - need to delete"
    HAS_RESOURCES=true
fi

if [ "$CERTS" != "[]" ] && [ -n "$CERTS" ]; then
    echo "✗ SSL certificates exist - need to delete"
    HAS_RESOURCES=true
fi

echo ""

if [ "$HAS_RESOURCES" = false ]; then
    echo "✅ No resources found - nothing to delete!"
    echo "Your AWS account is clean."
else
    echo "⚠️  Resources found that need deletion"
    echo ""
    echo "To delete them, run:"
    echo "  ./cleanup-aws-resources.sh"
fi

echo ""
