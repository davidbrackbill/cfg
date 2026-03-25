#!/bin/sh
cd "$1" || exit

repo=$(git config --get remote.origin.url | xargs basename | sed 's/.git$//')
branch=$(git branch --show-current | sed 's/^db\///')

[ "$repo" = "cfg" ] && exit
[ -z "$repo" ] || [ -z "$branch" ] && exit

echo " $repo/$branch"
