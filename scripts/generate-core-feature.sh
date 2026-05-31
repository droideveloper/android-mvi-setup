#!/bin/bash

# ============================================
# Feature Module Generator
# ============================================
# Usage: ./scripts/generate-core-feature.sh <FeatureName> [options]
#
# Options:
#   --package <package>      Base package name (default: com.mvi.core.<feature_lower>)
#   --arch common|library    Module context (default: library)
#   --type full|no-gateway   Selects what feature includes (default: full)  
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BASE_PACKAGE="com.mvi.core"
FEATURE_TYPE="full"
ARCH_TYPE="library"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

# Parse arguments
FEATURE_NAME=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --package)
            BASE_PACKAGE="$2"
            shift 2
            ;;
        --arch)
            ARCH_TYPE="$2"
            shift 2
            ;;
        --type)
            FEATURE_TYPE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 <FeatureName> [options]"
            echo ""
            echo "Options:"
            echo "  --package <package>      Base package name"
            echo "  --arch common|library    Module context (default: library)"
            echo "  --type full|no-gateway   Selects what feature includes (default: full)"
            exit 0
            ;;
        *)
            if [[ -z "$FEATURE_NAME" ]]; then
                FEATURE_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Validate feature name
if [[ -z "$FEATURE_NAME" ]]; then
    echo -e "${RED}Error: Feature name is required${NC}"
    echo "Usage: $0 <FeatureName>"
    exit 1
fi

# Convert names
FEATURE_LOWER=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]')
FEATURE_UPPER=$(echo "$FEATURE_NAME" | tr '[:lower:]' '[:upper:]')
FEATURE_CAMEL=$(echo "$FEATURE_NAME" | sed 's/\([A-Z]\)/_\L\1/g' | sed 's/^_//')

FULL_PACKAGE="$BASE_PACKAGE.$FEATURE_LOWER"
PACKAGE_PATH=$(echo "$FULL_PACKAGE" | tr '.' '/')

echo -e "${BLUE}🚀 Generating $FEATURE_NAME core module...${NC}"
echo -e "   Arch:    $ARCH_TYPE"
echo -e "   Package: $FULL_PACKAGE"
echo -e "   Type:    $FEATURE_TYPE"
echo ""

# Function to process template
process_template() {
    local template=$1
    local output=$2

    if [[ -f "$template" ]]; then
        sed -e "s/{{FEATURE_NAME}}/$FEATURE_NAME/g" \
            -e "s/{{FEATURE_LOWER}}/$FEATURE_LOWER/g" \
            -e "s/{{FEATURE_UPPER}}/$FEATURE_UPPER/g" \
            -e "s/{{FEATURE_NAME_CAMEL}}/$FEATURE_CAMEL/g" \
            -e "s/{{PACKAGE}}/$FULL_PACKAGE/g" \
            -e "s/{{FULL_PACKAGE}}/$FULL_PACKAGE/g" \
            -e "s/{{DATA_TYPE}}/Any/g" \
            "$template" > "$output"
        echo -e "${GREEN}✅ $(basename "$output")${NC}"
    else
        echo -e "${RED}❌ Template not found: $template${NC}"
    fi
}

# Create directory structure
FEATURE_DIR="./core/$FEATURE_LOWER"

mkdir -p "$FEATURE_DIR"

echo -e "${YELLOW}📁 Created $FEATURE_LOWER directory${NC}"

if [[ "$FEATURE_TYPE" == "full" ]]; then
    GATEWAY_DIR="$FEATURE_DIR/gateway"
    GATEWAY_MAIN_DIR="$GATEWAY_DIR/src/main/kotlin/$PACKAGE_PATH"
    GATEWAY_TEMPLATE_DIR="$TEMPLATE_DIR/mvi/core"

    mkdir -p "$GATEWAY_MAIN_DIR"

    echo -e "${YELLOW}📁 Created core/$FEATURE_LOWER/gateway directory${NC}"

    # Generate domain files
    process_template "$GATEWAY_TEMPLATE_DIR/common-build.gradle.kts.template" "$GATEWAY_DIR/build.gradle.kts"
    touch "$GATEWAY_DIR/.gitignore"
    echo "/build" >> "$GATEWAY_DIR/.gitignore"

    echo -e "${YELLOW}📁 SetUp :core:$FEATURE_LOWER:gateway module${NC}"

    IMPLEMENTATION_DIR="$FEATURE_DIR/implementation"
    IMPLEMENTATION_MAIN_DIR="$IMPLEMENTATION_DIR/src/main/kotlin/$PACKAGE_PATH"
    IMPLEMENTATION_TEMPLATE_DIR="$TEMPLATE_DIR/mvi/core"

    mkdir -p "$IMPLEMENTATION_MAIN_DIR"

    echo -e "${YELLOW}📁 Created core/$FEATURE_LOWER/implementation directory${NC}"

    # Generate domain files
    process_template "$IMPLEMENTATION_TEMPLATE_DIR/$ARCH_TYPE-implementation.build.gradle.kts.template" "$IMPLEMENTATION_DIR/build.gradle.kts"
    touch "$IMPLEMENTATION_DIR/.gitignore"
    echo "/build" >> "$IMPLEMENTATION_DIR/.gitignore"

    echo -e "${YELLOW}📁 SetUp :core:$FEATURE_LOWER:implementation module${NC}"
fi

if [[ "$FEATURE_TYPE" == "no-gateway" ]]; then

    IMPLEMENTATION_DIR="$FEATURE_DIR"
    IMPLEMENTATION_MAIN_DIR="$IMPLEMENTATION_DIR/src/main/kotlin/$PACKAGE_PATH"
    IMPLEMENTATION_TEMPLATE_DIR="$TEMPLATE_DIR/mvi/core"

    mkdir -p "$IMPLEMENTATION_MAIN_DIR"

    echo -e "${YELLOW}📁 Created core/$FEATURE_LOWER directory${NC}"

    # Generate domain files
    process_template "$IMPLEMENTATION_TEMPLATE_DIR/$ARCH_TYPE-build.gradle.kts.template" "$IMPLEMENTATION_DIR/build.gradle.kts"
    touch "$IMPLEMENTATION_DIR/.gitignore"
    echo "/build" >> "$IMPLEMENTATION_DIR/.gitignore"

    echo -e "${YELLOW}📁 SetUp :core:$FEATURE_LOWER module${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Feature module generated successfully!${NC}"
echo ""
echo -e "${BLUE}📁 Generated files:${NC}"
find "$FEATURE_DIR" -type f -name "*.kt" -o -name "*.kts" | sort | while read file; do
    echo "   $file"
done

echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "   1. Add module to settings.gradle.kts:"
if [[ "$FEATURE_TYPE" == "full" ]]; then
    echo "      include(\":core:$FEATURE_LOWER:gateway\")"
    echo "      include(\":core:$FEATURE_LOWER:implementation\")"

    echo "include(\":core:$FEATURE_LOWER:gateway\")" >> ./settings.gradle.kts
    echo "include(\":core:$FEATURE_LOWER:implementation\")" >> ./settings.gradle.kts
fi
if [[ "$FEATURE_TYPE" == "no-gateway" ]]; then
    echo "      include(\":core:$FEATURE_LOWER\")"

    echo "include(\":core:$FEATURE_LOWER\")" >> ./settings.gradle.kts
fi
echo ""
