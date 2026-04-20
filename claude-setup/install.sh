#!/usr/bin/env bash
set -euo pipefail

if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    echo "Error: bash 4+ required (found ${BASH_VERSION}). On macOS: brew install bash"
    exit 1
fi

# ==============================================================================
# Claude Code Environment Bootstrap
# Usage: bash install.sh
# Requires: git, claude (CLI), diff, jq
# ==============================================================================

REPO_URL="https://github.com/Vaibhav-Raheja/Vaibhav-Raheja"
REPO_DIR="/tmp/claude-setup-$$"
CLAUDE_DIR="$HOME/.claude"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Summary counters
MARKETPLACES_REGISTERED=()
PLUGINS_INSTALLED=()
PLUGINS_SKIPPED=()
CONFIG_OVERWRITTEN=()
CONFIG_SKIPPED=()
CONFIG_BACKED_UP=()
SKILLS_SYNCED=()
SKILLS_SKIPPED=()

# Cleanup temp dir on exit
trap 'rm -rf "$REPO_DIR"' EXIT

# ------------------------------------------------------------------------------
# 1. Prerequisites
# ------------------------------------------------------------------------------
check_prereqs() {
    echo -e "${CYAN}Checking prerequisites...${NC}"
    local missing=()
    for cmd in git claude diff jq; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing required commands: ${missing[*]}${NC}"
        echo "Install them and re-run this script."
        exit 1
    fi
    echo -e "${GREEN}All prerequisites satisfied.${NC}"
}

# ------------------------------------------------------------------------------
# 2. Fetch repo
# ------------------------------------------------------------------------------
fetch_repo() {
    echo -e "\n${CYAN}Cloning setup repo...${NC}"
    git clone --depth=1 "$REPO_URL" "$REPO_DIR" 2>&1 || {
        echo -e "${RED}Error: Failed to clone $REPO_URL${NC}"
        echo "Check your internet connection and that the repo is accessible."
        exit 1
    }
    echo -e "${GREEN}Repo cloned to $REPO_DIR${NC}"
}

# ------------------------------------------------------------------------------
# 3. Register marketplaces
# ------------------------------------------------------------------------------
register_marketplaces() {
    echo -e "\n${CYAN}Registering marketplaces...${NC}"

    declare -A MARKETS
    MARKETS["thedotmack"]="https://github.com/thedotmack/claude-mem"
    MARKETS["hex-plugins"]="https://github.com/hex/claude-marketplace"

    for name in "${!MARKETS[@]}"; do
        local source="${MARKETS[$name]}"
        # Check if already in known_marketplaces.json
        if jq -e --arg n "$name" '.[$n]' "$CLAUDE_DIR/plugins/known_marketplaces.json" &>/dev/null; then
            echo "  Marketplace '$name' already registered, skipping."
        else
            echo "  Registering marketplace: $name ($source)"
            if claude plugin marketplace add "$source" 2>&1; then
                MARKETPLACES_REGISTERED+=("$name")
                echo -e "  ${GREEN}Registered: $name${NC}"
            else
                echo -e "  ${YELLOW}Warning: Failed to register marketplace '$name' — continuing.${NC}"
            fi
        fi
    done
}

# ------------------------------------------------------------------------------
# 4. Install plugins
# ------------------------------------------------------------------------------
install_plugins() {
    echo -e "\n${CYAN}Installing plugins...${NC}"

    local plugins=(
        "claude-mem@thedotmack"
        "superpowers@claude-plugins-official"
        "frontend-design@claude-plugins-official"
        "github@claude-plugins-official"
        "claude-md-management@claude-plugins-official"
        "claude-code-setup@claude-plugins-official"
        "context7@claude-plugins-official"
        "claude-council@hex-plugins"
    )

    for plugin in "${plugins[@]}"; do
        # Check installed_plugins.json
        if jq -e --arg k "$plugin" '.plugins[$k]' \
               "$CLAUDE_DIR/plugins/installed_plugins.json" &>/dev/null; then
            echo "  Plugin '$plugin' already installed, skipping."
            PLUGINS_SKIPPED+=("$plugin")
        else
            echo "  Installing: $plugin"
            if claude plugin install "$plugin" 2>&1; then
                PLUGINS_INSTALLED+=("$plugin")
                echo -e "  ${GREEN}Installed: $plugin${NC}"
            else
                echo -e "  ${YELLOW}Warning: Failed to install '$plugin' — continuing.${NC}"
            fi
        fi
    done
}

# ------------------------------------------------------------------------------
# 5. Sync config files (merge/prompt)
# ------------------------------------------------------------------------------
merge_prompt() {
    local src="$1"
    local dst="$2"
    local name
    name="$(basename "$dst")"

    # Target doesn't exist — copy directly
    if [[ ! -f "$dst" ]]; then
        cp "$src" "$dst"
        CONFIG_OVERWRITTEN+=("$name")
        echo -e "  ${GREEN}Copied (new): $name${NC}"
        return
    fi

    # Files are identical — skip silently
    if diff -q "$src" "$dst" &>/dev/null; then
        echo "  No changes: $name (identical)"
        return
    fi

    # Files differ — show diff and prompt
    while true; do
        echo ""
        echo -e "  ${YELLOW}~/.claude/$name differs:${NC}"
        diff --color=always "$dst" "$src" | head -50 || true
        echo ""
        printf "  [O]verwrite  [S]kip  [B]ackup+overwrite  [V]iew full diff: "
        read -r choice || choice="S"
        case "${choice^^}" in
            O)
                cp "$src" "$dst"
                CONFIG_OVERWRITTEN+=("$name")
                echo -e "  ${GREEN}Overwritten: $name${NC}"
                return
                ;;
            S)
                CONFIG_SKIPPED+=("$name")
                echo "  Skipped: $name"
                return
                ;;
            B)
                cp "$dst" "${dst}.bak"
                cp "$src" "$dst"
                CONFIG_BACKED_UP+=("$name")
                echo -e "  ${GREEN}Backed up to ${name}.bak, overwritten: $name${NC}"
                return
                ;;
            V)
                diff --color=always "$dst" "$src" | less -R || true
                ;;
            *)
                echo "  Invalid choice. Enter O, S, B, or V."
                ;;
        esac
    done
}

sync_configs() {
    echo -e "\n${CYAN}Syncing config files...${NC}"
    local config_dir="$REPO_DIR/claude-setup/config"

    if [[ ! -d "$config_dir" ]]; then
        echo -e "${RED}Error: $config_dir not found in repo.${NC}"
        exit 1
    fi

    mkdir -p "$CLAUDE_DIR"
    shopt -s nullglob
    for src in "$config_dir"/*; do
        local name
        name="$(basename "$src")"
        merge_prompt "$src" "$CLAUDE_DIR/$name"
    done
    shopt -u nullglob
}

# ------------------------------------------------------------------------------
# 6. Sync skills
# ------------------------------------------------------------------------------
sync_skills() {
    echo -e "\n${CYAN}Syncing skills...${NC}"
    local skills_src="$REPO_DIR/claude-setup/skills"
    local skills_dst="$CLAUDE_DIR/skills"
    mkdir -p "$skills_dst"

    if [[ ! -d "$skills_src" ]]; then
        echo "  No skills directory found in repo, skipping."
        return
    fi

    shopt -s nullglob
    for skill_src in "$skills_src"/*/; do
        local skill_name
        skill_name="$(basename "$skill_src")"
        local skill_dst="$skills_dst/$skill_name"

        if [[ ! -d "$skill_dst" ]]; then
            cp -r "$skill_src" "$skill_dst"
            SKILLS_SYNCED+=("$skill_name")
            echo -e "  ${GREEN}Installed skill: $skill_name${NC}"
        elif diff -rq "$skill_src" "$skill_dst" &>/dev/null; then
            echo "  No changes: skill '$skill_name' (identical)"
        else
            echo ""
            echo -e "  ${YELLOW}Skill '$skill_name' differs:${NC}"
            diff -r "$skill_src" "$skill_dst" | head -20 || true
            echo ""
            while true; do
                printf "  [O]verwrite  [S]kip  [B]ackup+overwrite: "
                read -r choice || choice="S"
                case "${choice^^}" in
                    O)
                        rm -rf "$skill_dst"
                        cp -r "$skill_src" "$skill_dst"
                        SKILLS_SYNCED+=("$skill_name")
                        echo -e "  ${GREEN}Updated skill: $skill_name${NC}"
                        break
                        ;;
                    S)
                        SKILLS_SKIPPED+=("$skill_name")
                        echo "  Skipped skill: $skill_name"
                        break
                        ;;
                    B)
                        mv "$skill_dst" "${skill_dst}.bak"
                        cp -r "$skill_src" "$skill_dst"
                        SKILLS_SYNCED+=("$skill_name")
                        echo -e "  ${GREEN}Backed up and updated skill: $skill_name${NC}"
                        break
                        ;;
                    *)
                        echo "  Invalid choice. Enter O, S, or B."
                        ;;
                esac
            done
        fi
    done
    shopt -u nullglob
}

# ------------------------------------------------------------------------------
# 7. Summary
# ------------------------------------------------------------------------------
print_summary() {
    # Joins array elements with ", " or prints "none" if empty
    list_or_none() {
        if [[ $# -gt 0 ]]; then
            local IFS=", "; echo "$*"
        else
            echo "none"
        fi
    }

    echo ""
    echo -e "${CYAN}=== Claude Setup Complete ===${NC}"
    echo "Marketplaces registered : $(list_or_none "${MARKETPLACES_REGISTERED[@]+"${MARKETPLACES_REGISTERED[@]}"}")"
    echo "Plugins installed       : ${#PLUGINS_INSTALLED[@]} (skipped: ${#PLUGINS_SKIPPED[@]})"
    echo "Config files"
    echo "  Overwritten           : $(list_or_none "${CONFIG_OVERWRITTEN[@]+"${CONFIG_OVERWRITTEN[@]}"}")"
    echo "  Skipped               : $(list_or_none "${CONFIG_SKIPPED[@]+"${CONFIG_SKIPPED[@]}"}")"
    echo "  Backed up             : $(list_or_none "${CONFIG_BACKED_UP[@]+"${CONFIG_BACKED_UP[@]}"}")"
    echo "Skills synced           : $(list_or_none "${SKILLS_SYNCED[@]+"${SKILLS_SYNCED[@]}"}")"
    echo "Skills skipped          : $(list_or_none "${SKILLS_SKIPPED[@]+"${SKILLS_SKIPPED[@]}"}")"
    echo ""
    echo -e "${YELLOW}Note: Review ~/.claude/settings.json — update 'additionalDirectories' for this machine's paths.${NC}"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
echo -e "${CYAN}Claude Code Environment Bootstrap${NC}"
echo "Repo: $REPO_URL"
echo ""

check_prereqs
fetch_repo
register_marketplaces
install_plugins
sync_configs
sync_skills
print_summary
