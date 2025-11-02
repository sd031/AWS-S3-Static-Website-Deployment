# AWS S3 Static Website Deployment

A simple project demonstrating how to host a static website on AWS S3 using Infrastructure as Code (Terraform) and AWS CLI for deployment.

## 🎯 Project Goal

Host a static website in S3 using infrastructure as code and deploy it from the command line.

## 📚 Concepts Covered

- **AWS S3**: Static website hosting
- **Terraform**: Infrastructure as Code
- **AWS CLI**: Command-line deployment automation

## 📁 Project Structure

```
.
├── website/              # Static website files
│   ├── index.html       # Homepage
│   ├── error.html       # 404 error page
│   └── styles.css       # Stylesheet
├── terraform/           # Terraform configuration
│   ├── main.tf         # Main infrastructure definition
│   ├── variables.tf    # Input variables
│   ├── outputs.tf      # Output values
│   └── terraform.tfvars.example
├── deploy.sh           # Deployment script using AWS CLI
├── cleanup.sh          # Cleanup script to destroy all resources
└── README.md           # This file
```

## 🚀 Prerequisites

1. **AWS Account**: You need an active AWS account
2. **AWS CLI**: Install from [aws.amazon.com/cli](https://aws.amazon.com/cli/)
3. **Terraform**: Install from [terraform.io](https://www.terraform.io/downloads)
4. **AWS Credentials**: Configure with `aws configure`

## 📝 Quick Start (Simplified)

### Step 1: Configure AWS Credentials

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-east-1`)
- Default output format (e.g., `json`)

### Step 2: Deploy Everything

```bash
chmod +x deploy.sh
./deploy.sh my-static-website-unique-name-12345
```

Replace `my-static-website-unique-name-12345` with a **globally unique** bucket name.

> **Note**: S3 bucket names must be globally unique across all AWS accounts.

That's it! The script will:
1. ✅ Create `terraform.tfvars` automatically (if not exists)
2. ✅ Initialize Terraform
3. ✅ Deploy infrastructure (S3 bucket + configuration)
4. ✅ Upload website files
5. ✅ Display your website URL

Open the URL in your browser to see your deployed website! 🎉

## 📝 Manual Setup (Alternative)

If you prefer more control, you can deploy manually:

### Step 1: Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your bucket name:

```hcl
aws_region  = "us-east-1"
bucket_name = "my-static-website-unique-name-12345"
```

### Step 2: Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### Step 3: Deploy Website Files

```bash
cd ..
./deploy.sh <your-bucket-name>
```

## 🔄 Updating the Website

To update your website content:

1. Modify files in the `website/` directory
2. Run the deployment script:

```bash
./deploy.sh <your-bucket-name>
```

The script will sync your changes to S3.

## 🧹 Cleanup

To avoid ongoing AWS charges, destroy the infrastructure when done.

### Using the Cleanup Script (Recommended)

```bash
./cleanup.sh
```

That's it! The script will automatically:
- ✅ Retrieve bucket name from Terraform state
- ✅ Empty the S3 bucket (remove all files)
- ✅ Destroy all Terraform infrastructure
- ✅ Prompt for confirmation before proceeding

No need to remember or provide the bucket name!

### Manual Cleanup (Alternative)

```bash
# Empty the bucket first
aws s3 rm s3://<your-bucket-name> --recursive

# Then destroy infrastructure
cd terraform
terraform destroy
```

Type `yes` when prompted.

## 📖 What You'll Learn

### AWS S3 Concepts
- Creating S3 buckets
- Configuring static website hosting
- Setting bucket policies for public access
- Managing public access settings

### Terraform Concepts
- Provider configuration
- Resource definitions
- Variables and outputs
- State management

### AWS CLI Concepts
- Syncing files to S3
- Setting content types and cache headers
- Bucket operations

## 🛠️ Useful Commands

### Terraform Commands
```bash
terraform init          # Initialize Terraform
terraform plan          # Preview changes
terraform apply         # Apply changes
terraform destroy       # Destroy infrastructure
terraform output        # Show outputs
```

### AWS CLI Commands
```bash
# List bucket contents
aws s3 ls s3://<bucket-name>

# Sync files manually
aws s3 sync ./website s3://<bucket-name>

# Remove all files
aws s3 rm s3://<bucket-name> --recursive

# Check bucket website configuration
aws s3api get-bucket-website --bucket <bucket-name>
```

## 🔒 Security Notes

- This configuration makes the S3 bucket **publicly accessible** for static website hosting
- Do not store sensitive information in the website files
- The bucket policy allows read-only access to objects
- Consider adding CloudFront for HTTPS and better performance in production

## 💡 Next Steps

To enhance this project, consider:

1. **Add CloudFront**: Enable HTTPS and CDN caching
2. **Custom Domain**: Use Route 53 for a custom domain name
3. **CI/CD Pipeline**: Automate deployment with GitHub Actions
4. **Monitoring**: Add CloudWatch metrics and alarms
5. **Versioning**: Enable S3 versioning for backup

## 📄 License

This project is for educational purposes.

## 🤝 Contributing

Feel free to fork and modify this project for your learning!
