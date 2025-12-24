#!/bin/bash

# Chat System Verification Script
# This script helps verify that the chat system fixes are working correctly

echo "=========================================="
echo "Chat System Verification Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a function exists in functions.php
check_function() {
    local func_name=$1
    local file_path="/home/runner/work/ArtRocketRep/ArtRocketRep/functions.php"
    
    if grep -q "function $func_name" "$file_path"; then
        echo -e "${GREEN}✓${NC} Function $func_name exists"
        return 0
    else
        echo -e "${RED}✗${NC} Function $func_name NOT found"
        return 1
    fi
}

# Function to check if a fix pattern exists
check_fix() {
    local pattern=$1
    local description=$2
    local file_path="/home/runner/work/ArtRocketRep/ArtRocketRep/functions.php"
    
    if grep -q "$pattern" "$file_path"; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        return 1
    fi
}

echo "Checking critical chat functions..."
echo ""

# Check if main chat functions exist
check_function "ar_ajax_send_chat_message"
check_function "ar_ajax_get_chat_messages"
check_function "ar_ajax_check_new_messages"
check_function "ar_has_chat_access"
check_function "ar_get_unread_messages_count"
check_function "ar_client_get_unread_messages_count"

echo ""
echo "Checking security fixes..."
echo ""

# Check for SQL injection fix (spread operator)
check_fix '\.\.\.$params' "SQL Injection fix with spread operator"

# Check for rate limiting
check_fix "get_transient('ar_chat_last_message_'" "Rate limiting implementation"
check_fix "set_transient('ar_chat_last_message_'" "Rate limiting transient set"

# Check for input validation
check_fix 'if ($order_id <= 0 || $receiver_id <= 0)' "Input validation for positive IDs"
check_fix 'if ($user_id === $receiver_id)' "Self-messaging prevention"

# Check for table existence checks
check_fix 'SHOW TABLES LIKE' "Table existence checks"

# Check for error logging
check_fix "error_log('AR_CHAT:" "Error logging implementation"

# Check for typed format specifiers
check_fix "'\['\%d', '\%d', '\%d', '\%s', '\%d', '\%s'\]'" "Typed format specifiers in wpdb->insert"

echo ""
echo "Checking improvements..."
echo ""

# Check for strict type comparisons
check_fix 'intval(' "Type casting with intval()"

# Check for update_user_meta for activity tracking
check_fix "update_user_meta($user_id, 'ar_last_activity'" "User activity tracking"

echo ""
echo "=========================================="
echo "PHP Syntax Check"
echo "=========================================="
echo ""

# Check PHP syntax
php -l /home/runner/work/ArtRocketRep/ArtRocketRep/functions.php

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} PHP syntax is valid"
else
    echo -e "${RED}✗${NC} PHP syntax errors detected"
    exit 1
fi

echo ""
echo "=========================================="
echo "Verification Complete"
echo "=========================================="
echo ""
echo -e "${YELLOW}Note:${NC} This script only checks for the presence of fixes."
echo "Manual testing is still required to verify functionality."
echo ""
echo "Next steps:"
echo "1. Deploy to a test environment"
echo "2. Test sending messages between users"
echo "3. Test rate limiting by sending multiple messages quickly"
echo "4. Check WordPress debug.log for AR_CHAT entries"
echo "5. Verify access control works correctly"
echo ""
