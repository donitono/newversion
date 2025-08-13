#!/bin/bash

# Quick Update Script for Part2 Repository
# Usage: ./quick-update.sh "commit message"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Quick Update Script for Part2 Repository${NC}"
echo "=================================================="

# Get commit message
if [ -z "$1" ]; then
    echo -e "${BLUE}📝 Enter commit message:${NC}"
    read -r COMMIT_MSG
else
    COMMIT_MSG="$1"
fi

# Add all files
echo -e "${GREEN}📦 Adding all files...${NC}"
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo -e "${RED}❌ No changes to commit${NC}"
    exit 0
fi

# Commit changes
echo -e "${GREEN}💾 Committing changes...${NC}"
git commit -m "$COMMIT_MSG"

# Push to repository
echo -e "${GREEN}🌐 Pushing to GitHub...${NC}"
git push origin main

echo -e "${GREEN}✅ Successfully updated repository!${NC}"
echo ""
echo -e "${BLUE}📋 Your loadstring URLs:${NC}"
echo "Main Script: https://raw.githubusercontent.com/donitono/part2/main/main.lua"
echo "Standalone:  https://raw.githubusercontent.com/donitono/part2/main/skriplain.lua"
echo ""
