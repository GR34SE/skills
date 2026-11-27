#!/bin/sh

# Only the command fields: the payload also carries the model's narration
# (description in Claude Code, agent_message in Cursor).
cmd=$(grep -oE '"command" *: *"([^"\\]|\\.)*"')

printf '%s' "$cmd" | grep -Eq 'gh +pr +(create|new)|gh-axi +pr +create|no-mistakes +axi +run' || exit 0
printf '%s' "$cmd" | grep -Eq '# *degreaser-done' && exit 0

reason="degreaser: if this command opens a pull request, review the branch with degreaser first, now, as part of the same task. Load the degreaser skill and run it on this branch's changes against its base branch. Fix what the skill lets you fix without asking, commit those fixes on this branch, and make sure the pull request will include them. If it reports any finding that needs a decision, end your turn: show the findings to the user and do not open the pull request in this turn. When no finding waits for the user's decision, or when this command does not open a pull request, run it again with # degreaser-done added as a shell comment."

if [ "$1" = --cursor ]; then
  # cursor-agent 2026.11.22 shows the model only user_message, while Cursor's
  # docs name agent_message for that. The reason goes into the JSON unescaped,
  # so it must stay on one line and contain no double quotes or backslashes.
  printf '{"permission":"deny","user_message":"%s","agent_message":"%s"}\n' "$reason" "$reason"
  exit 0
fi

printf '%s\n' "$reason" >&2
exit 2
