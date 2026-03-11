#!/bin/bash

# MIRMI LLM Rebranding Script
# This script replaces all "MIRMI LLM" references with "MIRMI LLM"
# and removes external links to the original project

set -e

echo "🔄 Starting MIRMI LLM Rebranding Process..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create backup
BACKUP_DIR="rebranding-backup-$(date +%Y%m%d-%H%M%S)"
echo "📦 Creating backup in $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

# Function to replace text in files
replace_in_files() {
    local search="$1"
    local replace="$2"
    local description="$3"
    
    echo "🔍 Replacing: $description"
    
    # Find all text files (excluding binary files, node_modules, .git, etc.)
    find . -type f \
        -not -path "*/node_modules/*" \
        -not -path "*/.git/*" \
        -not -path "*/dist/*" \
        -not -path "*/build/*" \
        -not -path "*/.svelte-kit/*" \
        -not -path "*/static_backup_*/*" \
        -not -path "*/$BACKUP_DIR/*" \
        -not -path "*/rebranding-backup-*/*" \
        -not -path "*/nginx-backup-*/*" \
        -not -path "*/network-isolation-backup-*/*" \
        -not -path "*.whl" \
        -not -path "*.wasm" \
        -not -path "*.zip" \
        -not -path "*.tar.gz" \
        -not -path "*.png" \
        -not -path "*.jpg" \
        -not -path "*.jpeg" \
        -not -path "*.gif" \
        -not -path "*.ico" \
        -not -path "*.svg" \
        -not -path "*.ttf" \
        -not -path "*.woff*" \
        -not -path "*.mp3" \
        -exec grep -l "$search" {} \; 2>/dev/null | while read -r file; do
        
        # Backup original file
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        cp "$file" "$BACKUP_DIR/$file" 2>/dev/null || true
        
        # Perform replacement
        sed -i "s|$search|$replace|g" "$file"
    done
}

# 1. Replace "MIRMI LLM" with "MIRMI LLM"
echo ""
echo "Step 1: Replacing 'MIRMI LLM' with 'MIRMI LLM'..."
replace_in_files "MIRMI LLM" "MIRMI LLM" "'MIRMI LLM' → 'MIRMI LLM'"

# 2. Replace "mirmi-llm" with "mirmi-llm"
echo ""
echo "Step 2: Replacing 'mirmi-llm' with 'mirmi-llm'..."
replace_in_files "mirmi-llm" "mirmi-llm" "'mirmi-llm' → 'mirmi-llm'"

# 3. Replace "MIRMILLM" with "MIRMILLM"
echo ""
echo "Step 3: Replacing 'MIRMILLM' with 'MIRMILLM'..."
replace_in_files "MIRMILLM" "MIRMILLM" "'MIRMILLM' → 'MIRMILLM'"

# 4. Replace "open_webui" with "mirmi_llm"
echo ""
echo "Step 4: Replacing 'open_webui' with 'mirmi_llm'..."
replace_in_files "open_webui" "mirmi_llm" "'open_webui' → 'mirmi_llm'"

# 5. Remove external URLs and social media links
echo ""
echo "Step 5: Removing external URLs and social media links..."

# Remove openwebui.com references
replace_in_files "https://docs\.openwebui\.com[^\"' ]*" "" "docs.openwebui.com URLs"
replace_in_files "https://openwebui\.com[^\"' ]*" "" "openwebui.com URLs"
replace_in_files "https://www\.openwebui\.com[^\"' ]*" "" "www.openwebui.com URLs"
replace_in_files "https://api\.openwebui\.com[^\"' ]*" "" "api.openwebui.com URLs"
replace_in_files "https://careers\.openwebui\.com[^\"' ]*" "" "careers.openwebui.com URLs"
replace_in_files "https://licenses\.api\.openwebui\.com[^\"' ]*" "" "licenses.api.openwebui.com URLs"

# Remove GitHub references
replace_in_files "https://github\.com/mirmi-llm/mirmi-llm[^\"' ]*" "https://github.com/peymankhp/MIRMI-LLM" "GitHub URLs"
replace_in_files "https://github\.com/mirmi-llm/docs[^\"' ]*" "" "GitHub docs URLs"
replace_in_files "https://github\.com/mirmi-llm/pipelines[^\"' ]*" "" "GitHub pipelines URLs"

# Remove Discord links
replace_in_files "https://discord\.gg/5rJgQTnV4s" "" "Discord invite links"

# Remove social media references
replace_in_files "https://twitter\.com/MIRMILLM" "" "Twitter/X links"
replace_in_files "https://www\.reddit\.com/r/MIRMILLM" "" "Reddit links"

# 6. Update specific configuration files
echo ""
echo "Step 6: Updating configuration files..."

# Update package.json if it exists
if [ -f "package.json" ]; then
    echo "   Updating package.json..."
    sed -i 's/"name": "mirmi-llm"/"name": "mirmi-llm"/g' package.json
    sed -i 's/"MIRMI LLM"/"MIRMI LLM"/g' package.json
fi

# Update docker-compose files
for compose_file in docker-compose*.yaml docker-compose*.yml; do
    if [ -f "$compose_file" ]; then
        echo "   Updating $compose_file..."
        sed -i 's/container_name: mirmi-llm/container_name: mirmi-llm/g' "$compose_file"
        sed -i 's/image: ghcr\.io\/mirmi-llm\/mirmi-llm/image: ghcr.io\/peymankhp\/mirmi-llm/g' "$compose_file"
    fi
done

# Update README.md
if [ -f "README.md" ]; then
    echo "   Updating README.md..."
    # Remove badges
    sed -i '/!\[GitHub stars\]/d' README.md
    sed -i '/!\[GitHub forks\]/d' README.md
    sed -i '/!\[GitHub watchers\]/d' README.md
    sed -i '/!\[Discord\]/d' README.md
    sed -i '/!\[Sponsor\]/d' README.md
    
    # Remove enterprise and career sections
    sed -i '/Looking for an \[Enterprise Plan\]/,/Get \*\*enhanced capabilities\*\*/d' README.md
    sed -i '/Passionate about open-source AI/d' README.md
    
    # Remove star history section
    sed -i '/## Star History/,$d' README.md
    
    # Add MIRMI LLM specific content at the top
    sed -i '1s/^/# MIRMI LLM 🤖\n\n**MIRMI LLM** is a customized AI platform for the Munich Institute of Robotics and Machine Intelligence (MIRMI) at TUM.\n\n/' README.md
fi

# 7. Clean up specific files that shouldn't reference external projects
echo ""
echo "Step 7: Cleaning up documentation files..."

# Remove or update CONTRIBUTING.md
if [ -f "docs/CONTRIBUTING.md" ]; then
    echo "   Updating CONTRIBUTING.md..."
    cat > docs/CONTRIBUTING.md << 'EOF'
# Contributing to MIRMI LLM

Thank you for your interest in contributing to MIRMI LLM!

## Getting Started

This is a customized version of an open-source AI platform for MIRMI at TUM.

## Development

Please contact the MIRMI team for development guidelines and contribution procedures.

## Questions

For questions or support, please contact the MIRMI development team.
EOF
fi

# Update CODE_OF_CONDUCT.md
if [ -f "CODE_OF_CONDUCT.md" ]; then
    echo "   Updating CODE_OF_CONDUCT.md..."
    sed -i 's/hello@openwebui\.com/mirmi@tum.de/g' CODE_OF_CONDUCT.md
fi

# 8. Update environment and configuration files
echo ""
echo "Step 8: Updating environment files..."

if [ -f "backend/open_webui/env.py" ]; then
    mv backend/open_webui backend/mirmi_llm 2>/dev/null || true
fi

# 9. Update frontend references
echo ""
echo "Step 9: Updating frontend files..."

# Update Svelte components with external links
find src -type f -name "*.svelte" 2>/dev/null | while read -r file; do
    # Remove Discord and Twitter links from components
    sed -i '/href="https:\/\/discord\.gg/d' "$file"
    sed -i '/href="https:\/\/twitter\.com\/MIRMILLM/d' "$file"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Rebranding Complete!"
echo ""
echo "📊 Summary:"
echo "   - Replaced 'MIRMI LLM' with 'MIRMI LLM'"
echo "   - Replaced 'mirmi-llm' with 'mirmi-llm'"
echo "   - Removed external URLs (openwebui.com, docs, API)"
echo "   - Removed social media links (Discord, Twitter, Reddit)"
echo "   - Updated GitHub references to peymankhp/MIRMI-LLM"
echo "   - Updated configuration files"
echo ""
echo "📦 Backup saved to: $BACKUP_DIR"
echo ""
echo "⚠️  Next Steps:"
echo "   1. Review the changes: git diff"
echo "   2. Test the application to ensure everything works"
echo "   3. Commit the changes: git add -A && git commit -m 'Rebrand to MIRMI LLM'"
echo "   4. Push to GitHub: git push origin main"
echo ""
echo "🔄 To rollback: cp -r $BACKUP_DIR/* ."
echo ""
