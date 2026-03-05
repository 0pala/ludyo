#!/bin/bash

RED='\033[0;31m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
NC='\033[0m'

set -e

command -v flutter >/dev/null 2>&1 || { echo -e "${RED}Flutter not installed!${NC}"; exit 1; }

clear

echo -e "${PURPLE}Checks for errors...${NC}"
flutter analyze
echo -e "\n"

echo -e "${PURPLE}Sorting imports...${NC}"
dart run import_sorter:main
echo -e "\n"

echo -e "${PURPLE}Cleaning OLD builds...${NC}"
flutter clean
echo -e "\n"

echo -e "${PURPLE}Getting dependecies & Upgrading...${NC}"
flutter pub get
flutter pub upgrade
echo -e "\n"

echo -e "${PURPLE}Building release APK...${NC}"
flutter build apk --release --dart-define-from-file keys.json
echo -e "\n"

echo -e "${PURPLE}Installing APK to device...${NC}"
flutter install
echo -e "\n"

echo -e "${GREEN}Build Complete${NC}\n"