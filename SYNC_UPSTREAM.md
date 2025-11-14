# Syncing SkyCode OpenCode Fork with Upstream

This document explains how to keep the `skycode-opencode` fork synchronized with the upstream OpenCode repository.

## Strategy Overview

**Key Principle: Keep Fork Minimal for Easy Syncing**

- **Plugins Location**: SkyCode plugins are **NOT** in this fork
- **Plugins Location**: Plugins live in `skycode/packages/opencode-plugin/` (main repo)
- **Fork Purpose**: Version control, major incompatible changes, and OpenCode customization
- **Minimal Changes**: Keep fork as close to upstream as possible

## Why This Approach?

1. **Easy Upstream Syncs**: Minimal changes in fork = fewer conflicts
2. **Plugin Maintenance**: Plugins evolve separately from OpenCode
3. **Version Control**: Fork controls OpenCode version bundled with SkyCode
4. **Clean Separation**: Core OpenCode changes vs. SkyCode extensions

## Quick Start

```bash
cd skycode-opencode
./sync-upstream.sh
```

## Manual Sync Process

### 1. Add Upstream Remote (First Time Only)

```bash
cd skycode-opencode
git remote add upstream https://github.com/sst/opencode.git
git remote -v  # Verify remotes
```

### 2. Fetch Upstream Changes

```bash
git fetch upstream
```

### 3. Merge Upstream into Your Branch

```bash
# Switch to your working branch (e.g., main or dev)
git checkout dev  # or your branch name

# Merge upstream changes
git merge upstream/main
```

### 4. Resolve Conflicts (If Any)

If there are conflicts:

```bash
# Resolve conflicts in files
git status  # See conflicted files
# Edit files to resolve conflicts

# After resolving:
git add .
git commit -m "Merge upstream: resolve conflicts"
```

### 5. Push Changes

```bash
git push origin dev
```

## Automated Sync Script

The `sync-upstream.sh` script automates the sync process:

```bash
cd skycode-opencode
./sync-upstream.sh
```

**What it does:**

- Checks for upstream remote (adds if missing)
- Fetches upstream changes
- Stashes local uncommitted changes (if any)
- Merges upstream/main into current branch
- Restores stashed changes
- Shows summary

## Sync Strategy

### Recommended Frequency

- **Monthly**: Regular syncs to get upstream bug fixes and features
- **As Needed**: When upstream releases important features or fixes

### Branch Strategy

- **dev**: SkyCode's development branch (sync with upstream/main)
- **main**: Stable branch (sync before releases)
- **feature/\***: Feature branches (sync before merging)

### What to Keep in Fork vs. Main Repo

**In Fork (skycode-opencode):**

- ✅ Version pinning/compatibility changes
- ✅ Major incompatible behavior changes (rare)
- ✅ OpenCode core modifications needed for SkyCode
- ✅ Build configuration for bundling

**In Main Repo (skycode):**

- ✅ **All SkyCode plugins** (`packages/opencode-plugin/`)
- ✅ Plugin loading/integration logic
- ✅ SkyCode-specific configurations
- ✅ Settings import logic

### Conflict Resolution

When conflicts occur:

1. **Keep Minimal Changes in Fork**:
   - Only essential OpenCode core changes
   - Version compatibility fixes
   - Bundling-related modifications

2. **Move to Main Repo When Possible**:
   - Plugin-related changes → Main repo
   - Configuration changes → Main repo
   - Integration logic → Main repo

3. **Merge Both** (when applicable):
   - Documentation updates
   - Bug fixes that don't conflict

## Plugin Loading Strategy

Since plugins are in the main repo, they're loaded via:

1. **Build Time**: Bundle plugin with SkyCode
2. **Runtime**: OpenCode loads plugin from bundled location
3. **Configuration**: Point OpenCode to SkyCode plugin location

**Plugin Path**: `skycode/packages/opencode-plugin/`

## Verifying Sync

```bash
# Check commits ahead/behind upstream
git log upstream/main..HEAD  # Our commits not in upstream
git log HEAD..upstream/main  # Upstream commits we don't have

# Check diff summary
git diff --stat upstream/main..HEAD

# Should show minimal differences (only essential changes)
```

## Troubleshooting

### Upstream Remote Not Found

```bash
git remote add upstream https://github.com/sst/opencode.git
```

### Merge Conflicts

```bash
# See conflicted files
git status

# Use merge tool
git mergetool

# After resolving, complete merge
git add .
git commit
```

### Too Many Conflicts (Fork Drifted Too Far)

If fork has drifted significantly:

1. **Create backup branch**:

   ```bash
   git branch backup-before-reset
   ```

2. **Reset to upstream** (if changes are in main repo):

   ```bash
   git fetch upstream
   git reset --hard upstream/main
   ```

3. **Re-apply only essential changes**:
   - Re-add version pinning
   - Re-add bundling changes
   - Verify everything still works

### Stale Remote

```bash
# Update remote URL if needed
git remote set-url upstream https://github.com/sst/opencode.git

# Verify
git remote -v
```

## Best Practices

1. **Sync Regularly**: Don't let fork get too far behind
2. **Keep Changes Minimal**: Only essential changes in fork
3. **Move to Main Repo**: When possible, keep changes in main repo
4. **Test After Sync**: Run tests to ensure nothing broke
5. **Document Fork Changes**: Keep track of what's different and why
6. **Small Incremental Syncs**: Sync monthly rather than yearly

## CI/CD Integration (Future)

Consider adding automated sync checks:

- Weekly check for upstream updates
- Notification when upstream has changes
- Automated test runs after sync
- Automated conflict detection

## Related Documentation

- Architecture: `skycode/docs/architecture/opencode-integration-architecture.md`
- Plugin Implementation: `skycode/docs/plans/opencode-bundled-implementation.md`
- Plugin Code: `skycode/packages/opencode-plugin/`
