#!/bin/bash
# Claude Code statusLine command
# Derived from ~/.bashrc PS1: \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$
# Converted escape sequences:
#   \u → $(whoami)
#   \h → $(hostname -s)
#   \w → $(pwd)
#   trailing \$ removed
#
# Layout:
#   user@host:cwd (git-branch) [Model: effort | ctx:XX% | 5h:XX% 7d:XX%]

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
display_name=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
effort=$(echo "$input" | jq -r '.output_style.name // empty')

# Rate limit fields: present only for Claude.ai subscribers after first API response
five_hour_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

user=$(whoami)
host=$(hostname -s)

# Detect git branch using the cwd from the JSON input (skip optional locks)
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# Shorten model display name: strip leading "Claude " and keep the rest
# e.g. "Claude 3.5 Sonnet" → "Sonnet 3.5", "claude-sonnet-4-6" handled via display_name
# Strategy: if display_name matches "Claude X.Y Name", reorder to "Name X.Y"
short_model=""
if [ -n "$display_name" ]; then
    # Strip a leading "Claude " prefix (case-insensitive not needed; API uses title case)
    stripped="${display_name#Claude }"
    # If the remaining string starts with a digit (e.g. "3.5 Sonnet"), reorder to "Sonnet 3.5"
    first_char="${stripped:0:1}"
    if [[ "$first_char" =~ [0-9] ]]; then
        version=$(echo "$stripped" | awk '{print $1}')
        name=$(echo "$stripped" | awk '{$1=""; sub(/^ /, ""); print}')
        short_model="$name $version"
    else
        short_model="$stripped"
    fi
fi

# Normalize effort level: map known values to low/medium/high; omit if unrecognised or empty
effort_label=""
case "$effort" in
    low|Low|LOW)       effort_label="low" ;;
    medium|Medium|MEDIUM) effort_label="medium" ;;
    high|High|HIGH)    effort_label="high" ;;
    *)                 effort_label="" ;;
esac

# Build info block
info=""

# Model + optional effort
if [ -n "$short_model" ]; then
    if [ -n "$effort_label" ]; then
        info="${short_model}: ${effort_label}"
    else
        info="${short_model}"
    fi
fi

# Context usage: ctx:XX%
if [ -n "$used" ]; then
    ctx_str="ctx:$(printf '%.0f' "$used")%"
    if [ -n "$info" ]; then
        info="$info | $ctx_str"
    else
        info="$ctx_str"
    fi
fi

# Rate limits (only shown when the fields are present in the JSON)
rate_str=""
if [ -n "$five_hour_used" ]; then
    rate_str="5h:$(printf '%.0f' "$five_hour_used")%"
fi
if [ -n "$seven_day_used" ]; then
    rate_str="$rate_str 7d:$(printf '%.0f' "$seven_day_used")%"
fi
rate_str="${rate_str# }"  # trim leading space
if [ -n "$rate_str" ]; then
    if [ -n "$info" ]; then
        info="$info | $rate_str"
    else
        info="$rate_str"
    fi
fi

# PS1-style prefix: bold green user@host, bold blue full path
printf "\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m" "$user" "$host" "$cwd"

# Bold yellow (git-branch) when inside a git repo, nothing when not
if [ -n "$git_branch" ]; then
    printf " \033[01;33m(%s)\033[00m" "$git_branch"
fi

# Info block in [ ]
if [ -n "$info" ]; then
    printf " [%s]" "$info"
fi
printf "\n"
