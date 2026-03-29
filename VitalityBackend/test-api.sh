#!/bin/bash

# Vitality Backend - Quick Start Test Script

echo "=================================="
echo "Testing Vitality Backend APIs"
echo "=================================="

BASE_URL="http://localhost:8080/api"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test 1: User Registration
echo -e "\n${GREEN}Test 1: User Registration${NC}"
REGISTER_RESPONSE=$(curl -s -X POST ${BASE_URL}/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_'$(date +%s)'",
    "email": "test'$(date +%s)'@example.com",
    "password": "password123"
  }')

echo "$REGISTER_RESPONSE" | jq '.'

# Extract userId from response
USER_ID=$(echo "$REGISTER_RESPONSE" | jq -r '.data.userId')
echo -e "${GREEN}User ID: ${USER_ID}${NC}"

if [ -z "$USER_ID" ] || [ "$USER_ID" == "null" ]; then
  echo -e "${RED}Registration failed!${NC}"
  exit 1
fi

# Test 2: Get User Balance
echo -e "\n${GREEN}Test 2: Get User Balance${NC}"
curl -s -X GET ${BASE_URL}/users/${USER_ID}/balance | jq '.'

# Test 3: Sync Exercise Data
echo -e "\n${GREEN}Test 3: Sync Exercise Data${NC}"
curl -s -X POST ${BASE_URL}/exercise/sync \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "'${USER_ID}'",
    "steps": 5000,
    "calories": 350,
    "date": "'$(date +%Y-%m-%d)'"
  }' | jq '.'

# Test 4: Convert Calories to Coins
echo -e "\n${GREEN}Test 4: Convert Calories to Coins${NC}"
curl -s -X POST ${BASE_URL}/exercise/convert \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "'${USER_ID}'",
    "date": "'$(date +%Y-%m-%d)'"
  }' | jq '.'

# Test 5: Check-in
echo -e "\n${GREEN}Test 5: Check-in${NC}"
curl -s -X POST ${BASE_URL}/exercise/checkin \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "'${USER_ID}'"
  }' | jq '.'

# Test 6: Get User Statistics
echo -e "\n${GREEN}Test 6: Get User Statistics${NC}"
curl -s -X GET ${BASE_URL}/users/${USER_ID}/statistics | jq '.'

# Test 7: Get Exercise Records
echo -e "\n${GREEN}Test 7: Get Exercise Records${NC}"
curl -s -X GET "${BASE_URL}/exercise/records/${USER_ID}?startDate=2026-01-01&endDate=2026-12-31" | jq '.'

# Test 8: Login
echo -e "\n${GREEN}Test 8: User Login${NC}"
curl -s -X POST ${BASE_URL}/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "'$(echo "$REGISTER_RESPONSE" | jq -r '.data.email')'",
    "password": "password123"
  }' | jq '.'

echo -e "\n${GREEN}=================================="
echo "All tests completed!"
echo "==================================${NC}"
