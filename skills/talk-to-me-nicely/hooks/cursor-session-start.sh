#!/bin/sh
skill="$(dirname "$0")/../SKILL.md"
tab=$(printf '\t')
cr=$(printf '\r')
printf '{"additional_context":"'
sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$tab/\\\\t/g" -e "s/$cr\$//" "$skill" | awk '{ printf "%s\\n", $0 }'
printf '"}\n'
