#!/bin/bash

# ============================================
# Feature Templates installer
# ============================================
# Usage: ./install.sh <Folder>
# ============================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_DIR="$HOME/$1"

mkdir -p "$DEFAULT_DIR"

echo -e "${YELLOW}📁 Created $1 directory${NC}"

cp -r "$SCRIPT_DIR/scripts" "$DEFAULT_DIR"

echo -e "${GREEN}📁 copy scripts into $DEFAULT_DIR${NC}"

cp -r "$SCRIPT_DIR/templates" "$DEFAULT_DIR"

echo -e "${GREEN}📁 copy templates into $DEFAULT_DIR${NC}"

echo -e "${YELLOW}📁 adding aliases into .zshrc${NC}"

echo "" >> $HOME/.zshrc
echo "# core module alias" >> $HOME/.zshrc
echo "alias core-android=\"bash $DEFAULT_DIR/scripts/generate-core-feature.sh\"" >> $HOME/.zshrc
echo "alias core-common=\"bash $DEFAULT_DIR/scripts/generate-core-feature.sh --arch common\"" >> $HOME/.zshrc
echo "alias core-android-g=\"bash $DEFAULT_DIR/scripts/generate-core-feature.sh --type no-gateway\"" >> $HOME/.zshrc
echo "alias core-common-g=\"bash $DEFAULT_DIR/scripts/generate-core-feature.sh --arch common --type no-gateway\"" >> $HOME/.zshrc

echo -e "${GREEN}📁 added core aliases into ~/.zshrc${NC}"

echo "" >> $HOME/.zshrc
echo "# feature module alias" >> $HOME/.zshrc
echo "alias new-feature=\"bash $DEFAULT_DIR/scripts/generate-feature.sh\"" >> $HOME/.zshrc
echo "alias new-feature-d=\"bash $DEFAULT_DIR/scripts/generate-feature.sh --type no-data\"" >> $HOME/.zshrc

echo -e "${GREEN}📁 added feature aliases into ~/.zshrc${NC}"

source $HOME/.zshrc

echo ""
echo -e "${YELLOW}📝 Usage:${NC}"
echo ""
echo -e "${YELLOW}📝core-android Network${NC}"
echo -e "${GREEN}📁  :core:network:gateway -> common module${NC}"
echo -e "${GREEN}📁  :core:network:implementation -> android module${NC}"
echo -e "${GREEN}📁    generated and added into settings.gradle.kts${NC}"
echo ""
echo -e "${YELLOW}📝core-common Network${NC}"
echo -e "${GREEN}📁  :core:network:gateway -> common module${NC}"
echo -e "${GREEN}📁  :core:network:implementation -> common module${NC}"
echo -e "${GREEN}📁    generated and added into settings.gradle.kts${NC}"
echo ""
echo -e "${YELLOW}📝core-android-g Network${NC}"
echo -e "${GREEN}📁  :core:network -> android module${NC}"
echo -e "${GREEN}📁    generated and added into settings.gradle.kts${NC}"
echo ""
echo -e "${YELLOW}📝core-common-g Network${NC}"
echo -e "${GREEN}📁  :core:network -> common module${NC}"
echo -e "${GREEN}📁    generated and added into settings.gradle.kts${NC}"
echo ""
echo -e "${YELLOW}📝new-feature Weather --package org.example${NC}"
echo -e "${GREEN}📁  package will be \"org.example.weather\"${NC}"
echo -e "${GREEN}📁  :weather:data -> data module${NC}"
echo -e "${GREEN}📁  :weather:domain -> domain module${NC}"
echo -e "${GREEN}📁  :weather:ui -> ui module${NC}"
echo -e "${GREEN}📁    generated and added into settings.gradle.kts${NC}"
echo ""
echo -e "${YELLOW}📝new-feature-d Weather --package org.example${NC}"
echo -e "${GREEN}📁  package will be \"org.example.weather\"${NC}"
echo -e "${GREEN}📁  :weather:domain -> domain module${NC}"
echo -e "${GREEN}📁  :weather:ui -> ui module${NC}"
echo -e "${GREEN}📁    generated and added into settings.gradle.kts${NC}"
echo ""
echo -e "${GREEN}📝 Happy Coding!!${NC}"
echo ""

