# 🚀 Static Website Hosting on AWS S3 + CloudFront

Complete guide and automation scripts for hosting a static website on AWS S3 with CloudFront CDN, SSL certificate, and custom domain.

## 📋 Project Overview

This repository contains everything you need to host **srinathkaithoju.com** (or any static website) on AWS infrastructure:

- ☁️ **S3** for static file storage
- ⚡ **CloudFront** for global CDN
- 🔒 **ACM** for free SSL/TLS certificates
- 🌍 **Custom domain** configuration

## 📁 Repository Contents

### Documentation
- **[AWS-DEPLOYMENT-GUIDE.md](AWS-DEPLOYMENT-GUIDE.md)** - Complete step-by-step deployment guide
- **[CLEANUP-INSTRUCTIONS.md](CLEANUP-INSTRUCTIONS.md)** - How to delete all AWS resources
- **[RUN-CLEANUP-WINDOWS.md](RUN-CLEANUP-WINDOWS.md)** - Windows-specific cleanup instructions

### Automation Scripts
- **[cleanup-aws-resources.sh](cleanup-aws-resources.sh)** - Bash script for Mac/Linux/Git Bash
- **[cleanup-aws-resources.ps1](cleanup-aws-resources.ps1)** - PowerShell script for Windows

### Visual Resources
- **[aws-architecture-diagram.html](aws-architecture-diagram.html)** - Interactive architecture diagram
- **[tile-image.html](tile-image.html)** - Visual tile cards for presentations

## 🎯 Quick Start

### Deploy Your Website

1. **Follow the deployment guide:**
   ```bash
   # Read the complete guide
   cat AWS-DEPLOYMENT-GUIDE.md
   ```

2. **Key steps:**
   - Create S3 bucket in London (eu-west-2)
   - Upload your website files
   - Enable static website hosting
   - Request SSL certificate (us-east-1)
   - Create CloudFront distribution
   - Update DNS records

### Delete Resources

**Windows (PowerShell):**
```powershell
.\cleanup-aws-resources.ps1
```

**Mac/Linux/Git Bash:**
```bash
chmod +x cleanup-aws-resources.sh
./cleanup-aws-resources.sh
```

## 🏗️ Architecture

```
User → DNS → CloudFront (Global CDN) → S3 Bucket (London)
                ↓
           SSL Certificate (N. Virginia)
```

**Components:**
- **S3 Bucket**: `srinathkaithoju.com` in `eu-west-2` (London)
- **CloudFront**: Global edge locations for fast delivery
- **ACM Certificate**: Free SSL in `us-east-1` (required for CloudFront)
- **DNS**: CNAME records pointing to CloudFront

## 📊 Features

✅ **Global CDN** - Fast loading worldwide  
✅ **HTTPS/SSL** - Secure with free certificate  
✅ **Custom Domain** - Use your own domain name  
✅ **Scalable** - Handles traffic spikes automatically  
✅ **Cost-Effective** - Pay only for what you use (~$2-6/month)  
✅ **High Availability** - 99.99% uptime SLA  

## 💰 Cost Estimate

For a typical portfolio website:
- S3 Storage: ~$0.10-0.50/month
- CloudFront: ~$1-5/month
- SSL Certificate: FREE
- **Total: ~$2-6/month**

## 🔧 Prerequisites

- AWS Account
- AWS CLI installed and configured
- Domain name (e.g., srinathkaithoju.com)
- Access to domain registrar's DNS settings
- Website files (HTML, CSS, JS, images)

## 📖 Documentation

### Deployment Guide
The [AWS-DEPLOYMENT-GUIDE.md](AWS-DEPLOYMENT-GUIDE.md) includes:
- Step-by-step instructions with screenshots guidance
- Prerequisites and file preparation
- S3 bucket setup
- SSL certificate validation
- CloudFront configuration
- DNS setup
- Troubleshooting common issues
- Cost estimates
- Update procedures

### Cleanup Scripts
Automated scripts to delete all AWS resources:
- CloudFront distribution (disables first, then deletes)
- S3 bucket (empties then deletes)
- SSL certificate
- Checks for related resources

## 🎨 Visual Resources

### Architecture Diagram
Open `aws-architecture-diagram.html` in your browser to see:
- Interactive flow diagram
- Component relationships
- Implementation steps
- Regional information

### Tile Images
Open `tile-image.html` for presentation-ready cards showing:
- Architecture overview
- Benefits and features
- Tech stack details
- Performance metrics

## 🚀 Deployment Steps Summary

1. **Create S3 Bucket** (eu-west-2)
2. **Upload Website Files**
3. **Add Bucket Policy** (public read)
4. **Enable Static Hosting**
5. **Request SSL Certificate** (us-east-1)
6. **Validate Certificate** (add DNS CNAME)
7. **Create CloudFront Distribution**
8. **Update DNS Records** (point to CloudFront)
9. **Test Your Site** (https://yourdomain.com)

## 🔍 Testing

After deployment, verify:
- ✅ https://srinathkaithoju.com loads
- ✅ https://www.srinathkaithoju.com loads
- ✅ Green padlock (HTTPS working)
- ✅ Fast loading times globally
- ✅ All assets load correctly

## 🛠️ Troubleshooting

Common issues and solutions are documented in:
- [AWS-DEPLOYMENT-GUIDE.md](AWS-DEPLOYMENT-GUIDE.md#-troubleshooting)
- [CLEANUP-INSTRUCTIONS.md](CLEANUP-INSTRUCTIONS.md#troubleshooting)

## 📞 Support

For issues or questions:
1. Check the troubleshooting sections
2. Review AWS documentation
3. Verify AWS CLI configuration
4. Check AWS service status

## 🔄 Updates

To update your website:
1. Upload new files to S3
2. Create CloudFront invalidation (`/*`)
3. Wait 2-5 minutes for cache to clear

## 📝 License

This project is open source and available for educational purposes.

## 🙏 Acknowledgments

- AWS Documentation
- CloudFront Best Practices
- S3 Static Website Hosting Guide

## 🔗 Useful Links

- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS Certificate Manager](https://docs.aws.amazon.com/acm/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)

---

**Built for hosting static websites on AWS with best practices and automation** 🚀
