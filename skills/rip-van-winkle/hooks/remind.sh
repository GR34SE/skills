#!/bin/sh
# Reminds the agent of the rip-van-winkle skill. It never blocks anything:
# it prints a note for the model, or nothing.
#   remind.sh start   Session start: one note, before the agent plans.
#   remind.sh         Tool call, with the hook input on stdin: a note when the
#                     agent installs a package, scaffolds a project or writes
#                     a manifest.
#   --cursor          Print the note in Cursor's hook format. Without it the
#                     format is the one Claude Code and Codex read. The Pi
#                     extension reads that format too.

# sed and grep must accept every byte, also one that the user's locale rejects.
export LC_ALL=C

mode=tool
format=claude
for option in "$@"; do
  case "$option" in
    start) mode=start ;;
    --cursor) format=cursor ;;
  esac
done

emit() {
  if [ "$format" = cursor ]; then
    printf '{"additional_context":"%s"}\n' "$1"
  elif [ "$mode" = start ]; then
    printf '%s\n' "$1"
  else
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$1"
  fi
}

# Ends the script without a note. Cursor records a hook that prints nothing
# as a failed run, so Cursor gets an empty object.
quiet() {
  [ "$format" = cursor ] && echo '{}'
  exit 0
}

if [ "$mode" = start ]; then
  emit "rip-van-winkle: the versions, packages and APIs you remember are out of date. Before you plan a new project, choose or add a dependency, write a manifest, a config, a Dockerfile or a CI workflow, or pick a version of anything, load the rip-van-winkle skill and follow it. Load it before you decide on the stack, not after."
  exit 0
fi

input=$(cat)

# Prints the string value of the JSON key $1, still JSON-escaped.
field() {
  printf '%s' "$input" | sed -nE "s/.*\"$1\" *: *\"(([^\"\\\\]|\\\\.)*)\".*/\\1/p" | head -n 1
}

# Prints the shell command of the tool call in the form that the patterns
# below read. The JSON escapes are undone, a line break becomes ";", every
# quoted string becomes the letter Q, and a flag that takes a value is removed
# together with the value. So a word in a commit message is not read as a
# command, and the value of a flag is not read as a package.
shell_command() {
  field command | sed -E \
    -e 's/\\\\\\n/ /g' \
    -e 's/\\[nr]/;/g' \
    -e 's/\\t/ /g' \
    -e 's/\\"/"/g' \
    -e 's/\\\\/\\/g' \
    -e 's/\\.//g' \
    -e "s/\"[^\"]*\"|'[^']*'/Q/g" \
    -e 's/[[:space:]]+/ /g' \
    -e 's/ (--(requirement|constraint|editable|prefix|filter|dir|cwd|directory|project|target|path|root)|-[rceCFt]) [^ ;&|<>]+//g'
}

# Prints every file the tool call writes, one per line. Claude Code, Cursor
# and Pi name the file in file_path, Codex names it inside the patch text.
written_files() {
  printf '%s\n' "$(field file_path)"
  field command | grep -oE '\*\*\* (Add|Update) File: [^\\"]+' | sed 's/.*File: //'
}

word='[^ ;&|<>]'    # one character of a shell word
name='[^/\ ;&|<>]'  # one character of a file name
slash='[/\]'

# The start of a command: the start of the line or a separator, then wrappers
# and variable assignments.
at="(^|[;&|(]) ?((sudo|env|time|command|exec|then|do|else) |[A-Za-z_][A-Za-z0-9_]*=$word* )*"
# Flags after a subcommand, and flags before it, where a flag may take a value.
flags="( -$word*)*"
global="( -$word*( [^- ;&|<>]$word*)?)*"

scaffold="(npm|pnpm|yarn|bun)$global (create|init)|(npx|bunx|(pnpm|yarn)$global dlx|npm exec)$flags ($word*create-$word*|$word+ (new|init|create))|(cargo|poetry) (new|init)|(uv|deno|gradle)$global init|swift package init|go mod init|(rails|laravel|ng|nest) new|(django-admin|py(thon[0-9.]*)? -m django) startproject|composer create-project|dotnet new|mix (new|phx\.new)|flutter create"

# An install counts only when it names a package. "npm install" alone, or with
# a path, installs what the project already declares.
install="(npm|pnpm|bun)$global (i|install|add)|yarn( workspace $word+)?$global( global)? add|(uv|poetry|pdm|bundle|cargo|deno)$global add|(uv )?pip[0-9.]* install|py(thon[0-9.]*)? -m pip install|(cargo|go|gem|pipx|conda|mamba) install|go$global get|composer require|dotnet add( [^- ;&|<>]$word*)? package"
package="$flags (Q|@?[A-Za-z])"

manifest="package\.json|pyproject\.toml|requirements$name*\.txt|requirements$slash+$name+\.txt|setup\.py|Pipfile|Cargo\.toml|go\.mod|Gemfile|composer\.json|pom\.xml|build\.gradle(\.kts)?|$name*\.csproj|deno\.jsonc?|tsconfig$name*\.json|($name*\.)?Dockerfile(\.$name*)?|Containerfile|(docker-)?compose([.-]$name*)?\.ya?ml|\.nvmrc|\.node-version|\.python-version|\.ruby-version|\.tool-versions|\.?mise\.toml|rust-toolchain$name*|pnpm-workspace\.yaml|mix\.exs|pubspec\.yaml|\.gitlab-ci\.yml|\.github$slash+workflows$slash+$name+"

kind=""
case "$(field tool_name)" in
  Bash|Shell|PowerShell)
    command=$(shell_command)
    runs() {
      printf '%s' "$command" | grep -Eq "$1"
    }
    if runs "$at($scaffold)( |[;&|]|\$)"; then
      kind=scaffold
    elif runs "$at($install)$package"; then
      kind=install
    elif runs "(>|tee( -a)?) ?($name*$slash)*($manifest)( |[;&|<>]|\$)"; then
      kind=manifest
    fi
    ;;
  *)
    if written_files | grep -Eq "(^|$slash)($manifest)\$"; then
      kind=manifest
    fi
    ;;
esac

[ -n "$kind" ] || quiet

# A manifest is edited many times in a session, so each agent gets this note
# once. When the marker cannot be created, the note repeats.
if [ "$kind" = manifest ]; then
  session=$(field session_id)$(field conversation_id)$(field agent_id)
  if [ -n "$session" ]; then
    marker="${TMPDIR:-/tmp}/rip-van-winkle-$session"
    [ -e "$marker" ] && quiet
    mkdir "$marker" 2>/dev/null
  fi
fi

case "$kind" in
  install)
    note="rip-van-winkle: you are installing a package. First check that the language, the runtime or a framework already in this project does not cover this job at the version the project targets. Then check that you looked the package version up in the registry instead of remembering it. If either check fails, undo the install."
    ;;
  scaffold)
    note="rip-van-winkle: you are scaffolding a project. Look up the current LTS or stable version of the runtime and the framework, and the current form of this scaffolding command, before you rely on the result."
    ;;
  manifest)
    note="rip-van-winkle: you are writing a manifest or a config. This note is about what you add or choose in this edit, not about what the file already holds. Add no package for a job that the platform does by itself at the version the project targets. Take every version from a lookup or from an existing pin in this project, not from memory. Use the options that the current version of the tool documents."
    ;;
esac

emit "$note If the rip-van-winkle skill is not loaded in this session, load it now."
