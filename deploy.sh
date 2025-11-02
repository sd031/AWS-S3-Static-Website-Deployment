#!/bin/bash

# Complete deployment script: Terraform infrastructure + website files
# This script handles both infrastructure provisioning and content deployment

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== S3 Static Website Complete Deployment ===${NC}"

# Check if bucket name is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Bucket name not provided${NC}"
    echo "Usage: ./deploy.sh <bucket-name>"
    exit 1
fi

BUCKET_NAME=$1
WEBSITE_DIR="./website"
TERRAFORM_DIR="./terraform"

# Check if website directory exists
if [ ! -d "$WEBSITE_DIR" ]; then
    echo -e "${RED}Error: Website directory not found at $WEBSITE_DIR${NC}"
    exit 1
fi

# Check if terraform directory exists
if [ ! -d "$TERRAFORM_DIR" ]; then
    echo -e "${RED}Error: Terraform directory not found at $TERRAFORM_DIR${NC}"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    echo "Install it from: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed${NC}"
    echo "Install it from: https://www.terraform.io/downloads"
    exit 1
fi

# Step 1: Deploy Terraform Infrastructure
echo ""
echo -e "${BLUE}=== Step 1: Deploying Infrastructure with Terraform ===${NC}"
cd "$TERRAFORM_DIR"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}Warning: terraform.tfvars not found${NC}"
    echo "Creating terraform.tfvars with provided bucket name..."
    echo "aws_region  = \"us-east-1\"" > terraform.tfvars
    echo "bucket_name = \"$BUCKET_NAME\"" >> terraform.tfvars
    echo -e "${GREEN}✓ Created terraform.tfvars${NC}"
fi

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo -e "${BLUE}Initializing Terraform...${NC}"
    terraform init
fi

# Plan and Apply
echo -e "${BLUE}Planning infrastructure changes...${NC}"
terraform plan -out=tfplan

echo -e "${YELLOW}Applying infrastructure changes...${NC}"
terraform apply tfplan
rm -f tfplan

echo -e "${GREEN}✓ Infrastructure deployed successfully${NC}"

# Get bucket name from Terraform output
DEPLOYED_BUCKET=$(terraform output -raw bucket_name)
cd ..

# Verify bucket name matches
if [ "$DEPLOYED_BUCKET" != "$BUCKET_NAME" ]; then
    echo -e "${YELLOW}Warning: Deployed bucket name ($DEPLOYED_BUCKET) differs from provided name ($BUCKET_NAME)${NC}"
    BUCKET_NAME=$DEPLOYED_BUCKET
fi

# Step 2: Check if bucket exists and is accessible
echo ""
echo -e "${BLUE}=== Step 2: Verifying Bucket Access ===${NC}"
if ! aws s3 ls "s3://$BUCKET_NAME" 2>&1 > /dev/null; then
    echo -e "${RED}Error: Bucket $BUCKET_NAME is not accessible${NC}"
    echo "Please check your AWS credentials and permissions"
    exit 1
fi
echo -e "${GREEN}✓ Bucket is accessible${NC}"

# Step 3: Deploy Website Files
echo ""
echo -e "${BLUE}=== Step 3: Deploying Website Files ===${NC}"

# Sync website files to S3
echo -e "${BLUE}Uploading website files to S3...${NC}"
aws s3 sync "$WEBSITE_DIR" "s3://$BUCKET_NAME" \
    --delete \
    --cache-control "max-age=3600" \
    --exclude ".DS_Store"

# Set content types explicitly
echo -e "${BLUE}Setting content types...${NC}"
aws s3 cp "s3://$BUCKET_NAME/index.html" "s3://$BUCKET_NAME/index.html" \
    --content-type "text/html" \
    --metadata-directive REPLACE \
    --cache-control "max-age=3600"

aws s3 cp "s3://$BUCKET_NAME/error.html" "s3://$BUCKET_NAME/error.html" \
    --content-type "text/html" \
    --metadata-directive REPLACE \
    --cache-control "max-age=3600"

aws s3 cp "s3://$BUCKET_NAME/styles.css" "s3://$BUCKET_NAME/styles.css" \
    --content-type "text/css" \
    --metadata-directive REPLACE \
    --cache-control "max-age=86400"

echo -e "${GREEN}✓ Website files uploaded successfully${NC}"

# Step 4: Display Results
echo ""
echo -e "${GREEN}=== Deployment Complete! ===${NC}"
echo ""

# Get website URL from Terraform
cd "$TERRAFORM_DIR"
WEBSITE_URL=$(terraform output -raw website_url)
cd ..

echo -e "${GREEN}✓ Infrastructure: Deployed${NC}"
echo -e "${GREEN}✓ Website Files: Uploaded${NC}"
echo ""
echo -e "${BLUE}Your website is live at:${NC}"
echo -e "${GREEN}$WEBSITE_URL${NC}"
echo ""
echo "Bucket name: $BUCKET_NAME"
echo ""
echo "To update your website, modify files in ./website/ and run:"
echo "  ./deploy.sh $BUCKET_NAME"
