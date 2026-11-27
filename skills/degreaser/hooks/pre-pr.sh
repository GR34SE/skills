#!/bin/sh

input=$(cat)

printf '%s' "$input" | grep -Eq 'gh(-axi)? +pr +(create|new)|no-mistakes +axi +run' || exit 0
printf '%s' "$input" | grep -q 'DEGREASER_DONE=1' && exit 0

reason="degreaser: this pull request waits for a degreaser review, and you do it now as part of the same task. Load the degreaser skill and run it on this branch's changes against its base branch. Fix the slop it may fix without asking and commit those fixes on this branch. If it reports any finding that needs a decision, end your turn: show the findings to the user and do not open the pull request in this turn. Only when no finding waits for the user's decision, run the same command prefixed with DEGREASER_DONE=1."

if [ "$1" = --cursor ]; then
  printf '{"permission":"deny","user_message":"%s","agent_message":"%s"}\n' "$reason" "$reason"
  exit 0
fi

printf '%s\n' "$reason" >&2
exit 2
