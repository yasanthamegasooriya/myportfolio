#!/bin/bash

# Script to sync portfolio to S3 excluding specified folders
# Usage: ./deploy-s3.sh

# Configuration
TEMP_DIR="temp_deploy_$(date +%s)"
EXCLUDE_FOLDERS=("terraform" "node_modules" ".git")
S3_BUCKET="s3://yasanthamegasooriya.com"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting deployment process...${NC}"

# Create temporary directory
echo -e "${GREEN}Creating temporary directory: ${TEMP_DIR}${NC}"
mkdir -p "$TEMP_DIR"

# Copy all files and folders except excluded ones
echo -e "${GREEN}Copying files to temporary directory...${NC}"
for item in *; do
    # Check if item should be excluded
    exclude=false
    for excluded in "${EXCLUDE_FOLDERS[@]}"; do
        if [ "$item" = "$excluded" ]; then
            exclude=true
            echo -e "${YELLOW}Excluding: $item${NC}"
            break
        fi
    done
    
    # Copy if not excluded
    if [ "$exclude" = false ]; then
        echo "Copying: $item"
        cp -r "$item" "$TEMP_DIR/"
    fi
done

# Change to temporary directory
echo -e "${GREEN}Changing to temporary directory...${NC}"
cd "$TEMP_DIR" || exit 1

# Sync to S3
echo -e "${GREEN}Syncing to S3 bucket: ${S3_BUCKET}${NC}"
aws s3 sync . "$S3_BUCKET" --delete

# Check if sync was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}S3 sync completed successfully!${NC}"
else
    echo -e "${RED}S3 sync failed!${NC}"
    cd ..
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Go back to original directory
cd ..

# Clean up temporary directory
echo -e "${GREEN}Cleaning up temporary directory...${NC}"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${YELLOW}Your portfolio is now live at: http://yasanthamegasooriya.com${NC}"
