# AWS Resource Cleanup Script (PowerShell)
# This script deletes CloudFront, S3, and ACM resources for srinathkaithoju.com
# Regions: us-east-1 (N. Virginia) and eu-west-2 (London)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "AWS Resource Cleanup Script" -ForegroundColor Cyan
Write-Host "Domain: srinathkaithoju.com" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Variables
$BucketName = "srinathkaithoju.com"
$DomainName = "srinathkaithoju.com"
$LondonRegion = "eu-west-2"
$VirginiaRegion = "us-east-1"

Write-Host "⚠️  WARNING: This will delete all AWS resources for $DomainName" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Are you sure you want to continue? (type 'yes' to confirm)"

if ($confirm -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Step 1: Finding and Disabling CloudFront Distribution" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

try {
    # Get CloudFront distribution ID
    $distributions = aws cloudfront list-distributions --query "DistributionList.Items[?contains(Aliases.Items, '$DomainName')].{Id:Id,Status:Status}" --output json | ConvertFrom-Json
    
    if ($distributions) {
        $DistributionId = $distributions[0].Id
        Write-Host "Found CloudFront distribution: $DistributionId" -ForegroundColor Green
        
        # Get current distribution config
        Write-Host "Getting distribution configuration..."
        $etag = aws cloudfront get-distribution-config --id $DistributionId --query 'ETag' --output text
        
        # Get and save config
        aws cloudfront get-distribution-config --id $DistributionId --query 'DistributionConfig' | Out-File -FilePath "$env:TEMP\dist-config.json" -Encoding utf8
        
        # Disable the distribution
        Write-Host "Disabling CloudFront distribution..."
        $config = Get-Content "$env:TEMP\dist-config.json" | ConvertFrom-Json
        $config.Enabled = $false
        $config | ConvertTo-Json -Depth 100 | Out-File -FilePath "$env:TEMP\dist-config-disabled.json" -Encoding utf8
        
        aws cloudfront update-distribution --id $DistributionId --distribution-config "file://$env:TEMP\dist-config-disabled.json" --if-match $etag | Out-Null
        
        Write-Host "✓ CloudFront distribution disabled" -ForegroundColor Green
        Write-Host "⏳ Waiting for distribution to be fully disabled (this takes 5-15 minutes)..." -ForegroundColor Yellow
        
        # Wait for distribution to be disabled
        aws cloudfront wait distribution-deployed --id $DistributionId
        
        Write-Host "Deleting CloudFront distribution..."
        $newEtag = aws cloudfront get-distribution-config --id $DistributionId --query 'ETag' --output text
        aws cloudfront delete-distribution --id $DistributionId --if-match $newEtag
        
        Write-Host "✓ CloudFront distribution deleted" -ForegroundColor Green
        
        # Cleanup temp files
        Remove-Item "$env:TEMP\dist-config.json" -ErrorAction SilentlyContinue
        Remove-Item "$env:TEMP\dist-config-disabled.json" -ErrorAction SilentlyContinue
    } else {
        Write-Host "No CloudFront distribution found for $DomainName" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error with CloudFront: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Step 2: Emptying and Deleting S3 Bucket (London)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

try {
    # Check if bucket exists
    $bucketExists = aws s3api head-bucket --bucket $BucketName --region $LondonRegion 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Found S3 bucket: $BucketName in $LondonRegion" -ForegroundColor Green
        
        # Empty the bucket
        Write-Host "Emptying S3 bucket..."
        aws s3 rm "s3://$BucketName" --recursive --region $LondonRegion
        
        # Delete all versions (if versioning was enabled)
        Write-Host "Removing all versions and delete markers..."
        try {
            $versions = aws s3api list-object-versions --bucket $BucketName --region $LondonRegion --output json | ConvertFrom-Json
            
            if ($versions.Versions) {
                $versions.Versions | ForEach-Object {
                    aws s3api delete-object --bucket $BucketName --key $_.Key --version-id $_.VersionId --region $LondonRegion | Out-Null
                }
            }
            
            if ($versions.DeleteMarkers) {
                $versions.DeleteMarkers | ForEach-Object {
                    aws s3api delete-object --bucket $BucketName --key $_.Key --version-id $_.VersionId --region $LondonRegion | Out-Null
                }
            }
        } catch {
            Write-Host "No versions to delete" -ForegroundColor Yellow
        }
        
        Write-Host "✓ S3 bucket emptied" -ForegroundColor Green
        
        # Delete the bucket
        Write-Host "Deleting S3 bucket..."
        aws s3api delete-bucket --bucket $BucketName --region $LondonRegion
        
        Write-Host "✓ S3 bucket deleted" -ForegroundColor Green
    } else {
        Write-Host "No S3 bucket found: $BucketName in $LondonRegion" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error with S3: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Step 3: Deleting SSL Certificate (N. Virginia)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

try {
    # Get certificate ARN
    $certArn = aws acm list-certificates --region $VirginiaRegion --query "CertificateSummaryList[?DomainName=='$DomainName'].CertificateArn" --output text
    
    if ($certArn) {
        Write-Host "Found SSL certificate: $certArn" -ForegroundColor Green
        
        Write-Host "Deleting SSL certificate..."
        aws acm delete-certificate --certificate-arn $certArn --region $VirginiaRegion
        
        Write-Host "✓ SSL certificate deleted" -ForegroundColor Green
    } else {
        Write-Host "No SSL certificate found for $DomainName in $VirginiaRegion" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error with Certificate: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Step 4: Checking for Other Resources" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check for any other S3 buckets
Write-Host "Checking for other S3 buckets with 'srinath' in name..."
try {
    $otherBuckets = aws s3api list-buckets --query "Buckets[?contains(Name, 'srinath')].Name" --output text
    if ($otherBuckets) {
        Write-Host "Found other buckets:" -ForegroundColor Yellow
        Write-Host $otherBuckets
    } else {
        Write-Host "No other related buckets found" -ForegroundColor Green
    }
} catch {
    Write-Host "No other buckets found" -ForegroundColor Green
}

# Check for other certificates
Write-Host "Checking for other certificates in $VirginiaRegion..."
try {
    $otherCerts = aws acm list-certificates --region $VirginiaRegion --query "CertificateSummaryList[?contains(DomainName, 'srinath')].DomainName" --output text
    if ($otherCerts) {
        Write-Host "Found other certificates:" -ForegroundColor Yellow
        Write-Host $otherCerts
    } else {
        Write-Host "No other related certificates found" -ForegroundColor Green
    }
} catch {
    Write-Host "No other certificates found" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ Cleanup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resources deleted:"
Write-Host "  ✓ CloudFront distribution (if found)"
Write-Host "  ✓ S3 bucket: $BucketName (London)"
Write-Host "  ✓ SSL certificate (N. Virginia)"
Write-Host ""
Write-Host "Note: DNS records are NOT deleted by this script." -ForegroundColor Yellow
Write-Host "You need to manually remove CNAME records from your domain registrar if needed."
Write-Host ""
Write-Host "To verify deletion, run:"
Write-Host "  aws cloudfront list-distributions"
Write-Host "  aws s3 ls --region $LondonRegion"
Write-Host "  aws acm list-certificates --region $VirginiaRegion"
Write-Host ""
