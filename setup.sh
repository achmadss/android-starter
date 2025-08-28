#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_PROJECT_NAME="Android Starter"
DEFAULT_PACKAGE_NAME="com.example.androidstarter"
DEFAULT_MIN_SDK="26"

# Current values (what we're replacing)
CURRENT_PROJECT_NAME="Android Starter"
CURRENT_PACKAGE_NAME="com.example.androidstarter"
CURRENT_BASE_PACKAGE="com.example"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Android Starter Project Setup      ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result

    echo -e "${YELLOW}$prompt${NC}" >&2
    echo -e "${BLUE}Default: $default${NC}" >&2
    read -p "Enter value (or press Enter for default): " result

    if [ -z "$result" ]; then
        echo "$default"
    else
        echo "$result"
    fi
}

# Function to validate package name format
validate_package_name() {
    local package_name="$1"
    if [[ ! $package_name =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
        echo -e "${RED}Error: Invalid package name format. Use lowercase letters, numbers, underscores, and dots (e.g., com.company.appname)${NC}"
        return 1
    fi
    return 0
}

# Function to validate SDK version
validate_sdk_version() {
    local sdk_version="$1"
    if [[ ! $sdk_version =~ ^[0-9]+$ ]] || [ "$sdk_version" -lt 21 ] || [ "$sdk_version" -gt 35 ]; then
        echo -e "${RED}Error: Invalid SDK version. Must be a number between 21 and 35${NC}"
        return 1
    fi
    return 0
}

# Get user input
echo -e "${GREEN}Please provide the following information:${NC}"
echo ""

# Project Name
NEW_PROJECT_NAME=$(prompt_with_default "Project Name:" "$DEFAULT_PROJECT_NAME")

# Package Name with validation
while true; do
    NEW_PACKAGE_NAME=$(prompt_with_default "Package Name (for app module):" "$DEFAULT_PACKAGE_NAME")
    if validate_package_name "$NEW_PACKAGE_NAME"; then
        break
    fi
done

# Extract base package (everything except the last part)
NEW_BASE_PACKAGE=$(echo "$NEW_PACKAGE_NAME" | sed 's/\.[^.]*$//')

# Minimum SDK with validation
while true; do
    NEW_MIN_SDK=$(prompt_with_default "Minimum SDK Version:" "$DEFAULT_MIN_SDK")
    if validate_sdk_version "$NEW_MIN_SDK"; then
        break
    fi
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}           Configuration Summary         ${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Project Name:${NC} $NEW_PROJECT_NAME"
echo -e "${GREEN}App Package:${NC} $NEW_PACKAGE_NAME"
echo -e "${GREEN}Base Package:${NC} $NEW_BASE_PACKAGE"
echo -e "${GREEN}Core Package:${NC} $NEW_BASE_PACKAGE.core"
echo -e "${GREEN}Domain Package:${NC} $NEW_BASE_PACKAGE.domain"
echo -e "${GREEN}Data Package:${NC} $NEW_BASE_PACKAGE.data"
echo -e "${GREEN}Minimum SDK:${NC} $NEW_MIN_SDK"
echo ""

read -p "Do you want to proceed with these changes? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Setup cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Starting project setup...${NC}"

# Function to update files with sed (cross-platform compatible)
update_file() {
    local file="$1"
    local search="$2"
    local replace="$3"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|$search|$replace|g" "$file"
    else
        # Linux and others
        sed -i "s|$search|$replace|g" "$file"
    fi
}

# Function to update package declarations in source files
update_package_in_file() {
    local file="$1"
    local old_package="$2"
    local new_package="$3"

    echo "  Updating package in: $file"
    update_file "$file" "package $old_package" "package $new_package"
}

# Function to update import statements
update_imports_in_file() {
    local file="$1"
    local old_base="$2"
    local new_base="$3"

    echo "  Updating imports in: $file"
    update_file "$file" "import $old_base" "import $new_base"
    update_file "$file" "import $old_base." "import $new_base."
}

# Function to create new directory structure and move files
reorganize_source_files() {
    local module="$1"
    local old_package_path="$2"
    local new_package_path="$3"

    echo -e "${BLUE}Reorganizing source files for $module module...${NC}"

    # Define source directories
    local src_main="$module/src/main/java"
    local src_test="$module/src/test/java"
    local src_android_test="$module/src/androidTest/java"

    # Process each source directory if it exists
    for src_dir in "$src_main" "$src_test" "$src_android_test"; do
        if [ -d "$src_dir" ]; then
            local old_dir="$src_dir/$old_package_path"
            local new_dir="$src_dir/$new_package_path"

            if [ -d "$old_dir" ]; then
                echo "  Moving $old_dir to $new_dir"

                # Create new directory structure
                mkdir -p "$(dirname "$new_dir")"

                # Move the directory
                mv "$old_dir" "$new_dir"

                # Remove empty parent directories
                local parent_dir="$(dirname "$old_dir")"
                while [ "$parent_dir" != "$src_dir" ] && [ -d "$parent_dir" ] && [ -z "$(ls -A "$parent_dir")" ]; do
                    rmdir "$parent_dir"
                    parent_dir="$(dirname "$parent_dir")"
                done
            fi
        fi
    done
}

# 1. Update settings.gradle or settings.gradle.kts
echo -e "${BLUE}1. Updating project name in settings files...${NC}"
if [ -f "settings.gradle" ]; then
    echo "  Updating settings.gradle"
    update_file "settings.gradle" "rootProject.name = \"$CURRENT_PROJECT_NAME\"" "rootProject.name = \"$NEW_PROJECT_NAME\""
fi

if [ -f "settings.gradle.kts" ]; then
    echo "  Updating settings.gradle.kts"
    update_file "settings.gradle.kts" "rootProject.name = \"$CURRENT_PROJECT_NAME\"" "rootProject.name = \"$NEW_PROJECT_NAME\""
fi

# 2. Update build.gradle files for minimum SDK
echo -e "${BLUE}2. Updating minimum SDK version...${NC}"
for module in "app" "core" "domain" "data"; do
    if [ -f "$module/build.gradle" ]; then
        echo "  Updating $module/build.gradle"
        update_file "$module/build.gradle" "minSdk $DEFAULT_MIN_SDK" "minSdk $NEW_MIN_SDK"
        update_file "$module/build.gradle" "minSdkVersion $DEFAULT_MIN_SDK" "minSdkVersion $NEW_MIN_SDK"
    fi

    if [ -f "$module/build.gradle.kts" ]; then
        echo "  Updating $module/build.gradle.kts"
        update_file "$module/build.gradle.kts" "minSdk = $DEFAULT_MIN_SDK" "minSdk = $NEW_MIN_SDK"
        update_file "$module/build.gradle.kts" "minSdkVersion($DEFAULT_MIN_SDK)" "minSdkVersion($NEW_MIN_SDK)"
    fi
done

# 3. Update package names in build.gradle files
echo -e "${BLUE}3. Updating package names in build files...${NC}"
# App module
for gradle_file in "app/build.gradle" "app/build.gradle.kts"; do
    if [ -f "$gradle_file" ]; then
        echo "  Updating $gradle_file"
        update_file "$gradle_file" "applicationId \"$CURRENT_PACKAGE_NAME\"" "applicationId \"$NEW_PACKAGE_NAME\""
        update_file "$gradle_file" "namespace \"$CURRENT_PACKAGE_NAME\"" "namespace \"$NEW_PACKAGE_NAME\""
        update_file "$gradle_file" "namespace = \"$CURRENT_PACKAGE_NAME\"" "namespace = \"$NEW_PACKAGE_NAME\""
    fi
done

# Other modules (core, domain, data)
for module in "core" "domain" "data"; do
    for gradle_file in "$module/build.gradle" "$module/build.gradle.kts"; do
        if [ -f "$gradle_file" ]; then
            echo "  Updating $gradle_file"
            update_file "$gradle_file" "namespace \"$CURRENT_BASE_PACKAGE.$module\"" "namespace \"$NEW_BASE_PACKAGE.$module\""
            update_file "$gradle_file" "namespace = \"$CURRENT_BASE_PACKAGE.$module\"" "namespace = \"$NEW_BASE_PACKAGE.$module\""
        fi
    done
done

# 4. Update AndroidManifest.xml files
echo -e "${BLUE}4. Updating AndroidManifest.xml files...${NC}"
if [ -f "app/src/main/AndroidManifest.xml" ]; then
    echo "  Updating app/src/main/AndroidManifest.xml"
    update_file "app/src/main/AndroidManifest.xml" "package=\"$CURRENT_PACKAGE_NAME\"" "package=\"$NEW_PACKAGE_NAME\""
fi

# 5. Update source files and reorganize directory structure
echo -e "${BLUE}5. Updating source files and reorganizing directories...${NC}"

# Convert package names to directory paths
CURRENT_APP_PATH=$(echo "$CURRENT_PACKAGE_NAME" | tr '.' '/')
NEW_APP_PATH=$(echo "$NEW_PACKAGE_NAME" | tr '.' '/')
CURRENT_BASE_PATH=$(echo "$CURRENT_BASE_PACKAGE" | tr '.' '/')
NEW_BASE_PATH=$(echo "$NEW_BASE_PACKAGE" | tr '.' '/')

# Handle app module
if [ -d "app" ]; then
    echo -e "${YELLOW}Processing app module...${NC}"

    # First, let's find what the actual current app package is by looking at the manifest
    ACTUAL_CURRENT_PACKAGE=""
    if [ -f "app/src/main/AndroidManifest.xml" ]; then
        ACTUAL_CURRENT_PACKAGE=$(grep -o 'package="[^"]*"' app/src/main/AndroidManifest.xml | sed 's/package="//;s/"//')
        echo "  Detected current app package: $ACTUAL_CURRENT_PACKAGE"
    fi

    # Use the detected package or fall back to the default
    PACKAGE_TO_REPLACE="$ACTUAL_CURRENT_PACKAGE"
    if [ -z "$PACKAGE_TO_REPLACE" ]; then
        PACKAGE_TO_REPLACE="$CURRENT_PACKAGE_NAME"
    fi

    # Update package declarations and imports in all source files
    find app/src -name "*.kt" -o -name "*.java" | while read -r file; do
        # Update the main app package
        if grep -q "package $PACKAGE_TO_REPLACE" "$file" 2>/dev/null; then
            echo "  Updating package in: $file (from $PACKAGE_TO_REPLACE to $NEW_PACKAGE_NAME)"
            update_file "$file" "package $PACKAGE_TO_REPLACE" "package $NEW_PACKAGE_NAME"
        fi

        # Also handle sub-packages (e.g., com.example.androidstarter.ui -> dev.achmad.comuline.ui)
        if [ -n "$ACTUAL_CURRENT_PACKAGE" ]; then
            # Extract the app name from the current package (last part)
            CURRENT_APP_NAME=$(echo "$ACTUAL_CURRENT_PACKAGE" | sed 's/.*\.//')
            # Get base of current package
            CURRENT_APP_BASE=$(echo "$ACTUAL_CURRENT_PACKAGE" | sed 's/\.[^.]*$//')

            # Update sub-packages
            if grep -q "package $CURRENT_APP_BASE\.$CURRENT_APP_NAME\." "$file" 2>/dev/null; then
                echo "  Updating sub-packages in: $file"
                update_file "$file" "$CURRENT_APP_BASE\.$CURRENT_APP_NAME\." "$NEW_PACKAGE_NAME."
            fi
        fi

        # Update imports
        update_imports_in_file "$file" "$CURRENT_BASE_PACKAGE" "$NEW_BASE_PACKAGE"
    done

    # Reorganize directory structure using the actual detected package
    if [ -n "$ACTUAL_CURRENT_PACKAGE" ]; then
        ACTUAL_CURRENT_PATH=$(echo "$ACTUAL_CURRENT_PACKAGE" | tr '.' '/')
        reorganize_source_files "app" "$ACTUAL_CURRENT_PATH" "$NEW_APP_PATH"
    else
        reorganize_source_files "app" "$CURRENT_APP_PATH" "$NEW_APP_PATH"
    fi
fi

# Handle other modules (core, domain, data)
for module in "core" "domain" "data"; do
    if [ -d "$module" ]; then
        echo -e "${YELLOW}Processing $module module...${NC}"

        current_module_package="$CURRENT_BASE_PACKAGE.$module"
        new_module_package="$NEW_BASE_PACKAGE.$module"
        current_module_path="$CURRENT_BASE_PATH/$module"
        new_module_path="$NEW_BASE_PATH/$module"

        # Update package declarations and imports in all source files
        find "$module/src" -name "*.kt" -o -name "*.java" 2>/dev/null | while read -r file; do
            if grep -q "package $current_module_package" "$file" 2>/dev/null; then
                update_package_in_file "$file" "$current_module_package" "$new_module_package"
            fi
            # Update any imports that reference the old base package
            update_imports_in_file "$file" "$CURRENT_BASE_PACKAGE" "$NEW_BASE_PACKAGE"
        done

        # Reorganize directory structure
        reorganize_source_files "$module" "$current_module_path" "$new_module_path"
    fi
done

# 6. Update any remaining references in resource files
echo -e "${BLUE}6. Updating resource files...${NC}"
find . -name "*.xml" -not -path "./build/*" -not -path "./.git/*" | while read -r file; do
    if grep -q "$CURRENT_BASE_PACKAGE" "$file" 2>/dev/null; then
        echo "  Updating references in: $file"
        update_file "$file" "$CURRENT_BASE_PACKAGE" "$NEW_BASE_PACKAGE"
        update_file "$file" "$CURRENT_PACKAGE_NAME" "$NEW_PACKAGE_NAME"
    fi
done

# 7. Update proguard files if they exist
echo -e "${BLUE}7. Updating ProGuard files...${NC}"
find . -name "proguard-*.pro" -o -name "consumer-rules.pro" | while read -r file; do
    if [ -f "$file" ] && grep -q "$CURRENT_BASE_PACKAGE" "$file" 2>/dev/null; then
        echo "  Updating $file"
        update_file "$file" "$CURRENT_BASE_PACKAGE" "$NEW_BASE_PACKAGE"
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}         Setup Complete!                ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Changes made:${NC}"
echo "✓ Project name updated to: $NEW_PROJECT_NAME"
echo "✓ App package updated to: $NEW_PACKAGE_NAME"
echo "✓ Core module package updated to: $NEW_BASE_PACKAGE.core"
echo "✓ Domain module package updated to: $NEW_BASE_PACKAGE.domain"
echo "✓ Data module package updated to: $NEW_BASE_PACKAGE.data"
echo "✓ Minimum SDK updated to: $NEW_MIN_SDK"
echo "✓ Source files reorganized and updated"
echo "✓ Import statements updated"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Clean and rebuild your project"
echo "2. Run: ./gradlew clean build"
echo "3. Verify that all imports are working correctly"
echo "4. Update any hardcoded package references in your documentation"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"