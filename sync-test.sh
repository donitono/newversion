#!/bin/bash

# Sync and Test Script
# This script will sync changes and test lua syntax

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔄 Sync and Test Script${NC}"
echo "========================"

# Test lua syntax first
echo -e "${YELLOW}🧪 Testing Lua syntax...${NC}"

# Test main.lua
if luac -p main.lua 2>/dev/null; then
    echo -e "${GREEN}✅ main.lua syntax OK${NC}"
else
    echo -e "${RED}❌ main.lua has syntax errors${NC}"
    luac -p main.lua
    exit 1
fi

# Test ui.lua
if luac -p ui.lua 2>/dev/null; then
    echo -e "${GREEN}✅ ui.lua syntax OK${NC}"
else
    echo -e "${RED}❌ ui.lua has syntax errors${NC}"
    luac -p ui.lua
    exit 1
fi

# Test skriplain.lua
if luac -p skriplain.lua 2>/dev/null; then
    echo -e "${GREEN}✅ skriplain.lua syntax OK${NC}"
else
    echo -e "${RED}❌ skriplain.lua has syntax errors${NC}"
    luac -p skriplain.lua
    exit 1
fi

echo -e "${GREEN}🎉 All syntax tests passed!${NC}"
echo ""

# Commit message
if [ -z "$1" ]; then
    COMMIT_MSG="Auto-update: $(date '+%Y-%m-%d %H:%M:%S')"
else
    COMMIT_MSG="$1"
fi

# Git operations
echo -e "${BLUE}📦 Adding files...${NC}"
git add .

if git diff --staged --quiet; then
    echo -e "${YELLOW}⚠️ No changes to commit${NC}"
    exit 0
fi

echo -e "${BLUE}💾 Committing: $COMMIT_MSG${NC}"
git commit -m "$COMMIT_MSG"

echo -e "${BLUE}🌐 Pushing to GitHub...${NC}"
git push origin main

echo -e "${GREEN}✅ Repository updated successfully!${NC}"
echo ""
echo -e "${BLUE}🔗 Raw URLs for loadstring:${NC}"
echo "• Main: https://raw.githubusercontent.com/donitono/part2/main/main.lua"
echo "• Standalone: https://raw.githubusercontent.com/donitono/part2/main/skriplain.lua"
echo "• UI Framework: https://raw.githubusercontent.com/donitono/part2/main/ui.lua"
