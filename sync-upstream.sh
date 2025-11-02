#!/bin/bash
# Sync SkyCode OpenCode Fork with Upstream
# This script syncs the skycode-opencode fork with the upstream OpenCode repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔄 Syncing skycode-opencode fork with upstream..."

# Check if upstream remote exists
if ! git remote | grep -q "^upstream$"; then
    echo "📡 Adding upstream remote..."
    git remote add upstream https://github.com/opencode-ai/opencode.git || {
        echo "⚠️  Upstream remote might already exist with different URL"
        echo "   Current remotes:"
        git remote -v
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    }
fi

# Fetch upstream
echo "📥 Fetching upstream changes..."
git fetch upstream

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Check if there are local uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have uncommitted changes!"
    echo "   Stashing changes..."
    git stash push -m "Auto-stash before upstream sync $(date +%Y-%m-%d)"
    STASHED=true
else
    STASHED=false
fi

# Merge upstream changes
echo "🔀 Merging upstream/main into $CURRENT_BRANCH..."
git merge upstream/main --no-edit || {
    echo "❌ Merge conflict detected!"
    echo "   Resolve conflicts manually, then run:"
    echo "   git add ."
    echo "   git commit"
    
    if [ "$STASHED" = true ]; then
        echo "   Restoring stashed changes..."
        git stash pop
    fi
    
    exit 1
}

# If we stashed changes, restore them
if [ "$STASHED" = true ]; then
    echo "♻️  Restoring stashed changes..."
    git stash pop || {
        echo "⚠️  Could not automatically restore stashed changes"
        echo "   Run 'git stash list' to see stashed changes"
    }
fi

# Show summary
echo ""
echo "✅ Sync complete!"
echo ""
echo "📊 Summary:"
echo "   Branch: $CURRENT_BRANCH"
echo "   Upstream: $(git rev-parse upstream/main --short 2>/dev/null || echo 'N/A')"
echo "   Local: $(git rev-parse HEAD --short)"
echo ""
echo "💡 Next steps:"
echo "   1. Review changes: git log upstream/main..HEAD"
echo "   2. Test your changes"
echo "   3. Push to origin: git push"
echo ""

