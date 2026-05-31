#!/bin/bash

# ============================================
# Feature Module Generator
# ============================================
# Usage: ./scripts/generate-feature.sh <FeatureName> [options]
#
# Options:
#   --package <package>   Base package name
#   --type full|no-data   Selects what feature includes (default: full)  
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PATTERN="mvi" # Always MVI so skipp generation of different for now
BASE_PACKAGE="com.mvi"
FEATURE_TYPE="full"
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
        --type)
            FEATURE_TYPE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 <FeatureName> [options]"
            echo ""
            echo "Options:"
            echo "  --pattern mvi         Architecture pattern (default: mvi)"
            echo "  --package <package>   Base package name"
            echo "  --type full|no-data   Selects what feature includes (default: full)"
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

echo -e "${BLUE}🚀 Generating $FEATURE_NAME feature module...${NC}"
echo -e "   Pattern: $PATTERN"
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
            "$template" > "$output"
        echo -e "${GREEN}✅ $(basename "$output")${NC}"
    else
        echo -e "${RED}❌ Template not found: $template${NC}"
    fi
}

# Create directory structure
FEATURE_DIR="$FEATURE_LOWER"

mkdir -p "$FEATURE_DIR"

echo -e "${YELLOW}📁 Created $FEATURE_LOWER directory${NC}"

DOMAIN_DIR="$FEATURE_DIR/domain"
DOMAIN_MAIN_DIR="$DOMAIN_DIR/src/main/kotlin/$PACKAGE_PATH"
DOMAIN_TEMPLATE_DIR="$TEMPLATE_DIR/mvi/feature/domain"

mkdir -p "$DOMAIN_MAIN_DIR"
mkdir -p "$DOMAIN_MAIN_DIR/repo"
mkdir -p "$DOMAIN_MAIN_DIR/usecase"

echo -e "${YELLOW}📁 Created $FEATURE_LOWER:domain directory${NC}"

# Generate domain files
process_template "$DOMAIN_TEMPLATE_DIR/Domain.kt.template" "$DOMAIN_MAIN_DIR/${FEATURE_NAME}.kt"
process_template "$DOMAIN_TEMPLATE_DIR/Repository.kt.template" "$DOMAIN_MAIN_DIR/repo/${FEATURE_NAME}Repository.kt"
process_template "$DOMAIN_TEMPLATE_DIR/UseCase.kt.template" "$DOMAIN_MAIN_DIR/usecase/Get${FEATURE_NAME}UseCase.kt"
process_template "$DOMAIN_TEMPLATE_DIR/build.gradle.kts.template" "$DOMAIN_DIR/build.gradle.kts"
touch "$DOMAIN_DIR/.gitignore"
echo "/build" >> "$DOMAIN_DIR/.gitignore"

echo -e "${YELLOW}📁 SetUp $FEATURE_LOWER:domain module${NC}"

if [[ "$FEATURE_TYPE" == "full" ]]; then
    DATA_DIR="$FEATURE_DIR/data"
    DATA_MAIN_DIR="$DATA_DIR/src/main/kotlin/$PACKAGE_PATH"
    DATA_TEMPLATE_DIR="$TEMPLATE_DIR/mvi/feature/data"

    mkdir -p "$DATA_MAIN_DIR"
    mkdir -p "$DATA_MAIN_DIR/di"
    mkdir -p "$DATA_MAIN_DIR/repo"
    mkdir -p "$DATA_MAIN_DIR/service"

    echo -e "${YELLOW}📁 Created $FEATURE_LOWER:data directory${NC}"

    # Generate domain files
    process_template "$DATA_TEMPLATE_DIR/Data.kt.template" "$DATA_MAIN_DIR/Json${FEATURE_NAME}.kt"
    process_template "$DATA_TEMPLATE_DIR/DataModule.kt.template" "$DATA_MAIN_DIR/di/DataModule.kt"
    process_template "$DATA_TEMPLATE_DIR/Repository.kt.template" "$DATA_MAIN_DIR/repo/${FEATURE_NAME}RepositoryImpl.kt"
    process_template "$DATA_TEMPLATE_DIR/Service.kt.template" "$DATA_MAIN_DIR/service/${FEATURE_NAME}Service.kt"
    process_template "$DATA_TEMPLATE_DIR/build.gradle.kts.template" "$DATA_DIR/build.gradle.kts"
    touch "$DATA_DIR/.gitignore"
    echo "/build" >> "$DATA_DIR/.gitignore"

    echo -e "${YELLOW}📁 SetUp $FEATURE_LOWER:data module${NC}"
fi

UI_DIR="$FEATURE_DIR/ui"
UI_MAIN_DIR="$UI_DIR/src/main/kotlin/$PACKAGE_PATH"
UI_TEMPLATE_DIR="$TEMPLATE_DIR/mvi/feature/ui"

mkdir -p "$UI_MAIN_DIR"
mkdir -p "$UI_MAIN_DIR/di"

echo -e "${YELLOW}📁 Created $FEATURE_LOWER:ui directory${NC}"

process_template "$UI_TEMPLATE_DIR/Component.kt.template" "$UI_MAIN_DIR/di/${FEATURE_NAME}Component.kt"
process_template "$UI_TEMPLATE_DIR/Contract.kt.template" "$UI_MAIN_DIR/${FEATURE_NAME}Contract.kt"
process_template "$UI_TEMPLATE_DIR/Screen.kt.template" "$UI_MAIN_DIR/${FEATURE_NAME}Screen.kt"
process_template "$UI_TEMPLATE_DIR/ViewModel.kt.template" "$UI_MAIN_DIR/${FEATURE_NAME}ViewModel.kt"
if [[ "$FEATURE_TYPE" == "full" ]]; then
    process_template "$UI_TEMPLATE_DIR/build.gradle.kts.template" "$UI_DIR/build.gradle.kts"
fi
if [[ "$FEATURE_TYPE" == "no-data" ]]; then
    process_template "$UI_TEMPLATE_DIR/no-data.build.gradle.kts.template" "$UI_DIR/build.gradle.kts"
fi
touch "$UI_DIR/.gitignore"
echo "/build" >> "$UI_DIR/.gitignore"

echo -e "${YELLOW}📁 SetUp $FEATURE_LOWER:ui module${NC}"

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
    echo "      include(\":$FEATURE_LOWER:data\")"

    echo "include(\":$FEATURE_LOWER:data\")" >> ./settings.gradle.kts

fi
echo "      include(\":$FEATURE_LOWER:domain\")"
echo "      include(\":$FEATURE_LOWER:ui\")"

echo "include(\":$FEATURE_LOWER:domain\")" >> ./settings.gradle.kts
echo "include(\":$FEATURE_LOWER:ui\")" >> ./settings.gradle.kts
echo ""
echo "   2. Implement UseCase dependencies in ViewModel"
echo ""
echo "   3. Add Screen in composable"
echo "      ${FEATURE_NAME}Screen()"
