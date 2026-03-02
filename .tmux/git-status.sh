#!/bin/sh
cd "$1" || exit

repo=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
[ -z "$repo" ] && exit

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -z "$branch" ] && exit

# If branch has any slashes, keep only first and last segments
branch=$(echo "$branch" | awk -F/ 'NF > 1 { print $NF; next } { print }')

echo " $repo/$branch"
