#!/bin/bash

# Cleanup script to remove S3 bucket contents and destroy Terraform infrastructure
# Automatically retrieves bucket name from Terraform state

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== S3 Static Website Cleanup ===${NC}"

TERRAFORM_DIR="./terraform"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed${NC}"
    exit 1
fi

# Check if Terraform directory exists
if [ ! -d "$TERRAFORM_DIR" ]; then
    echo -e "${RED}Error: Terraform directory not found at $TERRAFORM_DIR${NC}"
    exit 1
fi

cd "$TERRAFORM_DIR"

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo -e "${YELLOW}No Terraform state found. Infrastructure may already be destroyed.${NC}"
    echo -e "${BLUE}Nothing to clean up.${NC}"
    cd ..
    exit 0
fi

# Get bucket name from Terraform state
echo -e "${BLUE}Retrieving bucket name from Terraform state...${NC}"
BUCKET_NAME=$(terraform output -raw bucket_name 2>/dev/null || echo "")

if [ -z "$BUCKET_NAME" ]; then
    echo -e "${YELLOW}Warning: Could not retrieve bucket name from Terraform state${NC}"
    echo -e "${YELLOW}Will proceed with Terraform destroy only${NC}"
else
    echo -e "${GREEN}Found bucket: $BUCKET_NAME${NC}"
fi

cd ..

# Confirmation prompt
echo ""
echo -e "${YELLOW}WARNING: This will delete all files in the S3 bucket and destroy the infrastructure.${NC}"
if [ -n "$BUCKET_NAME" ]; then
    echo -e "${YELLOW}Bucket: $BUCKET_NAME${NC}"
fi
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${BLUE}Cleanup cancelled.${NC}"
    exit 0
fi

# Empty the S3 bucket if bucket name was found
if [ -n "$BUCKET_NAME" ]; then
    echo ""
    echo -e "${BLUE}=== Step 1: Emptying S3 Bucket ===${NC}"
    
    if aws s3 ls "s3://$BUCKET_NAME" 2>&1 > /dev/null; then
        echo -e "${BLUE}Removing all files from S3 bucket...${NC}"
        aws s3 rm "s3://$BUCKET_NAME" --recursive
        echo -e "${GREEN}✓ Bucket emptied${NC}"
    else
        echo -e "${YELLOW}Bucket $BUCKET_NAME does not exist or is not accessible${NC}"
    fi
fi

# Destroy Terraform infrastructure
echo ""
echo -e "${BLUE}=== Step 2: Destroying Terraform Infrastructure ===${NC}"
cd "$TERRAFORM_DIR"

terraform destroy -auto-approve
echo -e "${GREEN}✓ Infrastructure destroyed${NC}"

cd ..

echo ""
echo -e "${GREEN}=== Cleanup Complete ===${NC}"
echo -e "${GREEN}All resources have been removed.${NC}"
